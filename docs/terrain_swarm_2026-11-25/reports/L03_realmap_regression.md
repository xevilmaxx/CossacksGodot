---
id: L03
ticket: "OWNER DIRECTIVE wave — L03 real-map ground regression"
title: "L03 — what makes the concentric maze on the fresh real-map capture, and the minimal fix"
owner: L03 (READ-ONLY analysis subagent)
created: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT__NO_DONOR_PARITY_CLAIM
scope: "Exactly one output file: this report. No .gd/.gdshader/.import/asset/test/config/queue edit; no Godot process; no runner job. Scratch analysis images were written only to C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ (outside the repo), mirroring G05's method."
output: docs/terrain_swarm_2026-11-25/reports/L03_realmap_regression.md
governing:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/terrain_swarm_2026-11-25/reports/A05_relief_visibility.md
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "No donor GPU A/B frame exists. No donor-parity claim is made anywhere in this report."
---

# L03 — real-map ground regression: the dense concentric maze

> Labels follow the charter: **OBSERVED** = pixel/file/source line read directly;
> **DERIVED** = arithmetic or control-flow consequence of observed lines/data;
> **INFERRED** = attribution with a caveat; **UNVERIFIED** = not provable with the
> available instruments. No Godot was run. No code was edited. **No donor parity claim.**

## 0. Provenance of what I opened (OBSERVED)

| Role | Path | Facts read |
|---|---|---|
| Fresh real-map capture | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\realmap.png` | 1280×720, 1,799,634 bytes, mtime 2026-11-25 15:08:08 |
| Same-run P0 stub | `...\g04\p0_64.png` | 1280×720, mtime 15:04:26; uniform olive, **no maze** |
| Runner record | `docs/.../reports/G04_gate_log.md:234-252` | ticket 589, capture source `Screenshot3DViewport`, camera `(144.1, 58.0, -88.6)` looking at `(384.1, 58.6)`, seed 20261113, `SCRIPT ERROR == 0` |
| Reference samples | `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg`, `articolo-787.jpg`, `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` | opened directly |
| Pre-B03 240² dump | `...\Temp\opencode\bapattern\dump240_20261113.json`, mtime 14:00:04 | 240², seed 20261113, base64 `height`/`tileblock`/`terrain`; decoded with Python+Pillow (scratch only) |
| Atlas art | `variant3d/assets/terrain/blocks/{rock1,rock3,rock4,rock8,rock9,ground1,grass_ground1,test7,test8}.png`, `variant3d/assets/terrain/atlas/alpha.png` | viewed as a contact sheet / direct image |

## 1. Ground patterns described in words BEFORE any verdict (OBSERVED)

This section is deliberately visual-only.

**Fresh real-map capture.** The ground is not a uniform field. Two distinct artificial
patterns dominate:

1. **Dense stair-stepped concentric "maze" / contour bands.** Large areas are covered by
   nested, closed, roughly octagonal rings, 1–2 map cells wide, made of **grey-brown
   material with strong vertical/diagonal striation and veining**. The rings are
   *stair-stepped* along cell edges (each corner advances in one-cell increments), so they
   read like a topographic contour map drawn with a thick charcoal pencil. They occur as
   isolated nested "eyelids" and as long chains of interlocking octagons that form a
   corridor-like maze. The nesting follows the rounded outlines of the large plateau /
   hill features; between the rings the ground is ordinary olive grass.
2. **Grid-aligned checkerboard patches.** Around buildings and resource/mine centres there
   are clean square blocks of alternating light tan/grey and olive, arranged on the map's
   cell lattice — most conspicuously the large square apron under the central structure
   and a smaller one to its right.

Elsewhere the frame has natural-looking olive grass, scattered conifers, a wooden tower
and two huts, and small units. There is no cyan water in the visible crop. No white
full-width dark row is apparent.

**Reference samples (same description protocol).** `cossacks-3-v1-498085.jpg` and
`articolo-787.jpg` show multi-hue green meadow with soft, metre-scale mottling, scattered
trees, and **a handful of irregular grey cliff faces** whose striations run vertically but
whose outlines are ragged and non-grid-aligned — never nested octagonal contours, never a
checkerboard. The highlands wallpaper adds grey scree and boulder fields, again irregular.
None of the three shows a repeated contour/maze or a square tile mosaic. This is a
comparative judgement only — **INFERRED**, not donor parity.

**P0 stub for contrast (OBSERVED).** `p0_64.png` is a flat olive field with fine grain and
a faint, low-amplitude horizontal striping; **no contour rings and no checkerboard at all**.
Therefore the maze requires real-map *data* (height/tile ids), not the shader alone.

**Atlas art identity (OBSERVED).** In the block contact sheet, `rock1` and `rock3` are
exactly the grey-brown vertically-striated / vein-like material seen inside the maze bands;
`rock4` is a darker striated grey-brown; `ground1` is the fine grey-brown dirt matching the
checkerboard aprons; `grass9`, `test7`, `test8` are clean olive and cannot produce grey
striations. `alpha.png` is a grid of **soft blobby** masks with no nested/ring geometry.

## 2. Verdict — which of (a)/(b)/(c)/(d) is it? (INFERRED, caveated)

**The maze is (a) height-driven rock-art promotion — but NOT B04's shader face-mode.
It is the older `game.gd` cliff-tile path that paints rock *tile ids* into `tileblock`.**
The checkerboard squares are a secondary contribution from **(b) `ground1` painting**
(roads / mine aprons / B03-P2 stamp painting). **(c) alpha-mask patches are refuted** as
the contour source. **(d) atlas art repetition supplies the striation *texture*, not the
nesting geometry.**

Critical correction to the ticket's premise (OBSERVED + DERIVED):

* `variant3d/scripts/world3d_terrain.gd` is **83,687 bytes**, byte-for-byte identical to
  `inbox/backup/world3d_terrain.gd.bak-B04` (also 83,687 bytes, both mtime 14:56:43),
  and contains **no** `B04`, `_relief_face_at`, `B04_RELIEF_GATE_FRACTION` or
  `B04_MIN_GATE` token. The B04 implementation described in
  `B04_relief_impl.md:93-259` is **not in the working tree** and was not in the 15:08
  capture (the revert predates the capture by ~2 h 12 min). Do not attribute the maze to
  B04 and do not "fix" it by re-applying B04 — that path would add *more* face-promoted
  rock art (B04 report §7.3 explicitly warns about over-promotion on real maps).
* The surviving `_face_mode_at()` (`world3d_terrain.gd:756-778`) still uses the verbatim
  donor `cDiff` gates `0.5 / 0.55` (`:161-162`, `:764-772`). A05 §3.7/:240-249 and §4 rank 4
  establish that those deltas never occur on the port's 1–4° slopes, so `face` stays 0,
  `_donor_cliff_name()` at `:1340-1354` is never reached, and UV2.y is 0 everywhere.
  Rock art in this frame therefore reaches the screen through **UV2.x → `tileblock`**,
  not through UV2.y.

## 3. Ranked root-cause list (exact `file:line`)

### Rank 1 — Cliff-role gradient gate promotes base-height terraces to rock tile art `[CONFIRMED mechanism; visual share INFERRED]`

* `variant3d/scripts/game.gd:1275-1308` — the collision pass: cardinal `|dh|>0.5`
  (`:1285-1292`) / diagonal `>0.55` (`:1293-1296`) sets `terrain[i]=5` for any steep land
  cell, and `:1308` always marks it blocked. The terraces that trigger this come from the
  discrete 8-bit R-code relief (`mapgen.gd:63-85`, cited in A05 §2/:81-83) and the clamp
  bands at `game.gd:1069`, `:1117`, `:1254-1274`.
* `variant3d/scripts/game.gd:1298-1305` — an existing comment already names the symptom:
  *"Their terraced rims … must not be painted as rock ART — that is the owner's concentric
  maze."* The guard at `:1306` (`if _relief_stamp_mask[i] == 0`) only excludes cells inside
  relief stamps; steep cells on **base-mask** quantization terraces outside that mask are
  still promoted. That is the residual path that produces the observed rings.
* `variant3d/scripts/game.gd:2166-2177` `_apply_shore_cliffs()` — role-5 cells are written
  to `tileblock` via `_cliff_tile_for()`.
* `variant3d/scripts/game.gd:2130-2164` `_cliff_tile_for()` — aspect sectors return
  `rock1`/`rock3`/`rock4` (`:2140-2163`), with absolute-height gates `|h|>2.7 → rock8`
  (`:2158-2159`) and `>2.4 → rock4` (`:2160-2161`). Multiple height bands ⇒ multiple
  nested rings with different grey art.
* `variant3d/scripts/world3d_terrain.gd:1324`, `:1407` — `tileblock` id becomes UV2.x; the
  shader `tile_rgb` samples that atlas cell, so the rock art is what the eye sees.

Corroboration (DERIVED from the pre-B03 dump): decoding `bapattern/dump240_20261113.json`
gives `terrain==5` on 1,494 / 57,600 cells, and plotting that role forms **thin arcs and
partial rings around the plateau/water features** (scratch `l03_height.png`,
`l03_role5.png`, `l03_idmap_color.png`). Rock ids `{20,23,24,25}` occupy ~2,456 cells and
`ground1` (10) 741 cells. The dump predates B03's 14:33 edit, so **the maze is pre-B03**;
reverting B03 alone cannot remove it.

### Rank 2 — Quantised / clipped height creates the terraces that feed rank 1 `[CONFIRMED source; contribution DERIVED]`

* `variant3d/scripts/mapgen.gd:63-85` (R-code decode) and `:87-94` (`relief_smooth`
  exposed, not consumed) — discrete relief levels, cited verbatim in A05 §2/:81-84.
* `variant3d/scripts/game.gd:1069`, `:1117` — stamp relief clamped to
  `[-2.964, +2.964]`, creating flat terraces at the bounds.
* `variant3d/scripts/game.gd:1267-1274` — the 0.03 dither intentionally splits the
  saturated plateau cap into two levels (`2.964` / `2.934`), adding another contour band.
* A05 §3.2/:137-161 and §4 rank 1 identify amplitude-vs-footprint and this quantisation as
  the primary geometry cause of the "flat but stepped" look.

### Rank 3 — `ground1` painting produces the checkerboard aprons and extra grey regions `[CONFIRMED code; visual share INFERRED]`

* `variant3d/scripts/game.gd:1995-2004` — road cells: 50 % `ground1`, rest `test2/test3`.
* `variant3d/scripts/game.gd:2035-2039` — mine apron overrides the whole footprint with
  `ground1`.
* `variant3d/scripts/game.gd:2049-2072` — **terrain-swarm B03 P2**: every `kind=="tile"`
  stamp cell is painted `ground1` (reported at `B03_diversity_impl.md:83-113,149-151`).
* A03 §2 row `ground1` / F06: mean `(99.8, 90.7, 66.3)`, grey-brown, diagonal scratches,
  Sx 1.40, **"not grass"**. This is category (b), and it is secondary for the maze but
  primary for the square aprons.

### Rank 4 — Intrinsic atlas lattice art is still reachable `[CONFIRMED code+A03 measurement; contribution to THIS frame UNVERIFIED]`

* `variant3d/scripts/game.gd:1922-1961` `_apply_detail_pass()` paints ids read from
  `tile_lowground.png` / `tile_highground.png`. Decoded histograms: id 1 (`grass2`) at
  7.4 % / 3.7 % of the 320² bitmaps; ids 78/79/80/83/84/85 dominate the rest.
* A03 §2/F03: `grass_ground1/2/3` (14/15/16) carry a bright diagonal vein lattice; F04:
  `grass2` has FFT-aniso 5.16 and Sy 1.81 (vertical banding). B03-P3
  (`game.gd:2196-2210`) redirects only the *smoothing* draws, not a bitmap that directly
  encodes those ids, so this lane is not provably closed in the current capture.
* This is category (d): it supplies the *texture* inside the bands, not the ring geometry.

### Rank 5 — Alpha-mask patches `[REFUTED as the contour source]`

* `variant3d/assets/terrain/atlas/alpha.png` is 8×4 soft blobs; the shader
  `terrain_tileindex.gdshader:365-378,405-419` picks one 64² sub-rect and folds it into RGB
  through `mask_to_alpha=1` at `:427`. There is no nested-ring geometry in that data, and
  A02 Q4 (quoted in `B01_shader_impl.md:107-110`) warns that a border-band mask would draw
  a **2 m square grid**, not contours. Category (c) is not the cause.

### Non-causes / provenance caveats

* **B04 face-mode:** absent from tree and capture (see §2). Not a cause here.
* **B01 continuous warp / B02 mip chain:** `terrain_tileindex.gdshader:334-337` warp has a
  ~48 m wavelength (v_st is world X/Z because `st` uses `worldpos` at `:311` and
  `texture_matrix` is identity at `:122`), far larger than the observed ~5-cell band
  spacing; and `p0_64.png`, captured with the same shader family, has no maze. Not a cause
  of the rings. **Keep** these improvements (see §4).
* **Capture-provenance caveat (UNVERIFIED):** the shader file mtime is 15:09:33, *after*
  the 15:08:08 capture; `B01_shader_impl.md:69-77` records that the per-cell mirror variant
  was removed only after an owner verdict on `p0_64.png`. The capture therefore may have
  been rendered with the pre-revision shader. That is a plausible secondary source of the
  **checkerboard** squares (B01 §9 calls the mirror "a chessboard"), but the exact
  capture-time shader bytes are **UNVERIFIED** — there is no snapshot of that intermediate
  state. The maze itself is independent of it (dump evidence, rank 1).

## 4. Minimal revert / fix that restores clean organic ground and keeps mip/linear/mask improvements

**Proposal only — no edit made, no test weakened, no runner submitted.** The minimal,
disjoint change is in **`variant3d/scripts/game.gd` only**, at the rank-1 site:

1. **Primary (one-site fix):** at `game.gd:1297-1308`, stop the gradient-driven cliff
   promotion from writing rock art on base-height terraces. Keep `set_blocked_tile(x,y,true)`
   at `:1308` so walkability/start protection are unchanged. The smallest form is to make
   the role-5 assignment at `:1306-1307` never fire (previously it already excludes
   relief-stamp cells); if some rock art must remain, gate it on both
   `_relief_stamp_mask[i] != 0` **and** `absf(height[i]) > DONOR_ROCK4_H` so only genuinely
   high, stamped plateau caps qualify. This removes the striated contour rings while
   leaving the linear/mip/mask work in the shader and loader completely untouched.
2. **Secondary (only if checkerboard persists after a fresh capture):** revert the
   terrain-swarm B03-P2 hunk at `game.gd:2049-2072` (the `tls_* → ground1` painting). It is
   an additive PORT APPROX with no donor parity, and B03's own report
   (`B03_diversity_impl.md:188-190`) calls it a small, structurally real restoration on only
   four stamps. Keep B03-P1 (`:1945-1959`) and B03-P3 (`:2196-2210`); neither produces grey
   rings.
3. **Do NOT revert:** `terrain_tileindex.gdshader:60` `filter_linear_mipmap`; `:329-337`
   half-texel inset + `textureGrad` + unwrapped-UV derivatives (A06-F2); `:405-419` sentinel
   guard + mask contrast compression (A02-P1/P4); `tile_atlas_loader.gd` runtime mip chain
   and the `.import` `mipmaps=true` (B02). None of these is implicated, and the ticket
   requires keeping them.
4. **Do NOT re-apply B04.** Its relief-aware face promotion would add face-mode rock art on
   top of the tile-id rock art.
5. **Acceptance (requires a new capture by the sole runner owner — not performed here):**
   fresh real-map + 64² captures at the same seed/camera, `script_error_lines == 0`,
   `full_width_dark_rows == 0`, selftest 29/29, `t_render_mode` PASS, `assert_clean CLEAN`,
   and a second-agent read confirming no nested contours/checkerboard. Any improvement is
   still **UNVERIFIED** for donor parity — no donor GPU A/B frame exists.

## 5. Claim ledger

| Claim | Label | Evidence |
|---|---|---|
| Maze is stair-stepped nested grey striated contours; checkerboard aprons exist | OBSERVED | `g04/realmap.png` view, §1 |
| Donor samples have irregular sparse cliffs and no maze/grid | OBSERVED / INFERRED comparison | three `c3/*.jpg` views, §1 |
| P0 stub has no maze ⇒ real-map data is required | OBSERVED + DERIVED | `g04/p0_64.png` view, §2 |
| `world3d_terrain.gd` equals B04 backup; B04 not in tree/capture | OBSERVED + DERIVED | identical 83,687-byte files, mtimes, token grep, §2 |
| Face mode stays 0; rock art reaches screen via tile id | DERIVED | `world3d_terrain.gd:756-778,1332,1340-1354,1407`; A05 §3.7 |
| Cliff gradient gate + `_apply_shore_cliffs` paint rock tile ids in rings | CONFIRMED mechanism / INFERRED visual share | `game.gd:1275-1308,2166-2177,2130-2164`; dump role-5 ring plot |
| Maze predates B03 | DERIVED | dump mtime 14:00 < `game.gd` B03 mtime 14:33, both show rings |
| `ground1` art is grey-brown/off-palette | OBSERVED | A03 §2 row 10 / F06; block contact sheet |
| Alpha masks do not produce ring geometry | OBSERVED + REFUTED | `alpha.png` view; shader `:365-378,405-419` |
| Capture may predate shader revision ⇒ checkerboard source partly UNVERIFIED | UNVERIFIED | shader mtime 15:09:33 > capture 15:08:08; B01 §9 |
| Donor parity of any pixel | UNVERIFIED | no donor GPU A/B frame |

---

*End of L03. One report written; no source, shader, asset, config, test, backup, queue or
git edit; no Godot process; no runner job; no donor-parity claim.*
