---
id: H05
ticket: "TERRAIN-SWARM-WAVE-G / H05 — independent second opinion on the owner's heightmap-layer hypothesis"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "ONE report written. No code, shader, asset, config, test, git or runner-job change. H03 was NOT read before this verdict was formed."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
verdict: REFUTED
parity_claim: false
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (Wave H, :106-126)
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/A08_donor_truth_local.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md
  - docs/terrain_swarm_2026-11-25/reports/A02_alpha_pattern.md
  - docs/terrain_swarm_2026-11-25/reports/G15_tile_measure.md (corroborating histogram)
  - docs/terrain_swarm_2026-11-25/reports/A05_relief_visibility.md (corroborating relief chain)
  - variant3d/shaders/terrain_tileindex.gdshader (fragment/vertex/mask paths)
  - variant3d/scripts/world3d_terrain.gd, game.gd, mapgen.gd (read-only trace)
---

# H05 — Refutation of the heightmap-layer hypothesis (independent second opinion)

## 0. Mandate and independence

Wave H charter (:106-126) records the owner's hypothesis: *"one of the terrain layers, the one
that produces strange patterns, should not be visible but used for heightmap only."* The ticket
asks whether the visible diagonal/vein patterns can plausibly come from a layer that the donor
uses **only** for height or tile selection, or whether they are inherent to the **visible tile
art and alpha crossfade**.

This verdict was formed from the five assigned documents plus a direct read-only trace of the
port code. **H03's conclusion was not consulted while forming it.** The agreement/disagreement
note with H03 is appended only after this report was written.

Label key: **[O]** observed (literal source line / pixel / measured value), **[D]** derived
(arithmetic or control-flow consequence), **[I]** inference, **[U]** UNVERIFIED. No donor GPU
A/B frame exists (CHARTER §3; A08 §8.10), so **no donor-parity claim is made** anywhere below.

---

## 1. Verdict

> **REFUTED.** The visible diagonal/vein patterns are **not** a mis-displayed donor height or
> tile-selection layer. They are properties of layers the port (and the donor) **do display**:
> the per-cell atlas albedo art and the alpha-atlas crossfade. Every candidate height/selection
> layer in the charter's list is consumed as data (height grid, tile id, blend weight) and is
> **not bound as visible albedo** in the wired render path. Routing the pattern layer to height
> would remove donor tile identity, void the published `mask_to_alpha` A/B, and bypass the
> mesh's height invariants without removing the cause of the streaks.

Two charitable readings are separated so the verdict is not over-stated:

| Reading of the hypothesis | Verdict | Why |
|---|---|---|
| A. A donor height-only/selection-only layer is currently drawn as albedo in our render | **REFUTED** | Direct code trace §3 — no such layer is bound to the tileindex shader's albedo sampler |
| B. The layer producing the veins should be hidden and repurposed as the height input | **REFUTED** | The vein layer *is* visible donor tile art; the donor uses the alpha mask as a *visible* crossfade, not height (§4) |
| C. Height/selection inputs drive *which* art appears, so stronger height use would reduce the patterns | **PARTLY TRUE AS A DESCRIPTION, REFUTED AS A CAUSE** | The port already derives height, tile ids and face modes from these inputs (§3); the repeated veins are in the selected art itself (§4), not in the input selection |

---

## 2. Direct answers to the ticket's two questions

**Q1 — Can the patterns plausibly come from a height/mask layer the donor uses only for height
or tile selection?** **No [O]/[D].** In the port, `fragment()` never samples a height texture
(shader `:388-476`). Height is a CPU-side per-cell float grid baked into vertex Y
(`world3d_terrain.gd:1392`) and consumed by normals (`:981-996`), face/shore/cliff promotion
(`:1413-1487`) and water (`bind_height_grid()`, `:1179`). The only texture samples in the
fragment are `tile_atlas` (`:337`, via `:392`), `alpha_atlas` (`:417`) and `alphavert_atlas`
(`:407`), plus shadow/fog terms. None of these is a height source in donor: `alpha.bmp` is an
8×4 grid of 64² *feather masks* used for the visible `bmTransparency` crossfade (A08 §2; shader
`:340-364` cites the donor geometry), and `alphavert` is the cliff-face alpha projection
(A08 §2, donor `reftile.mat:120-169`).

**Q2 — Or are they inherent to the visible tile art and alpha crossfade?** **Yes [O]/[D].**
The atlas cells are byte-identical copies of the shipped block PNGs (A03 E01), and the cells
carrying the owner's "diagonal streaks" are measured to contain those streaks *in the art*:
`grass_ground1/2/3` show a bright diagonal vein lattice / crosshatch with the highest coarse
structure in the set (A03 §2 rows 14/15/16, F03, R02); `ground1` has diagonal scratches (F06);
`grass2` has FFT-aniso 5.16 vertical banding (F04). Separately, the alpha patch is applied to
**every** cell with the 2 m `fract` phase and folded into RGB (shader `:417`, `:427`; A02
Q1/Q2), reusing only 32 patch shapes across 124 ids (A02 §2). Both mechanisms are on the
**visible** path. That is the source of the patterns.

---

## 3. Layer-by-layer trace: donor role vs port role vs "drawn as albedo?"

| Candidate layer (charter :112-114) | Donor role (A08 / port citations) | Port consumption | Drawn as albedo in wired render? |
|---|---|---|---|
| `terrainmask` TGA R/G/B | R relief, G forest/stone, B water, white=start → **generates** height and map shape (`game.gd:1117-1125`; `mapgen.gd:1-9`) | Decoded into `height[]` / forest / starts in `C3MapGen.build()` (`game.gd:1139-1143`) | **No** — never a shader sampler |
| `tile_lowground.bmp` / `tile_highground.bmp` | Detail-bitmap variety pass: `h<0.1` selects bitmap, `tex=floor(r*255) div 2`, **only where id still 0**; mottling is *tile identity*, not luminance (A08 §1.2) | Tile **id** selection only: `game.gd:1903-1952` `_apply_detail_pass()` writes `tileblock[i] = tex` | **No** — sets an id, not RGB |
| `alpha.png` / `alphavert.png` masks | Visible `bmTransparency` crossfade weight at seams; "mask intensity only … **not** a colour layer, a height ramp, a distance field, or a noise source" (A08 §2) | Repacked R→A (`world3d_terrain.gd:664-675,694-707`), sampled as `a` (`:407`,`:417`) and **multiplied into RGB** (`:427`) | Visible, but as a **modulator**, not a height source |
| `.map` height bytes | Donor map format; port has no public spec (`menu.gd:7`) | Port generates height from masks instead; no `.map` byte path | **No** |
| `pattern` float32 relief grids | Authored height windows stamped into relief (A08 §4) | Optional `apply_relief_grid()` into `height[]` (`world3d_terrain.gd:507-541`); no `relief_stamps` marker in current schema (`:564-597`) | **No** — numeric grid, not an image |
| Port `game.height` / `tileblock` arrays | Analogue of `TMapTerrainDataTile{height,tex,collision[4]}` (`game.gd:128-136`) | `height[]` → mesh Y (`world3d_terrain.gd:1392`), normals, face promotion, water; `tileblock` → `UV2.x` tile id (`:1053-1075`, shader `:324`) | Height: **no**. Tile id: yes — *that is the donor-faithful albedo selector* |

**Decisive check — is any height layer actually drawn as albedo today? [O]** The wired material
is `_tileindex_material()` when tiles and atlas are available (`world3d_terrain.gd:1534-1546`),
with samplers bound at `:721-724` (`tile_atlas`, `alpha_atlas`, `alphavert_atlas`). The only
height-derived image on disk, `splat_albedo.png`, is explicitly *"normalised height DATA …
**never blend it**"* (`:761`) and is used only in the V7-82 fallback (`:1541-1545`), labelled
"PORT APPROXIMATION — NOT DONOR PARITY". Likewise `heightmapwaves0.tga` is *deliberately NOT
bound* in the water path (`water3d.gd:95`; A08 §8.8). So the "hidden height layer being shown as
albedo" premise has no instance in the current render.

---

## 4. Why the patterns are inherent to the visible art + crossfade (not height)

1. **The art itself contains the streaks [O].** A03 E01: atlas cell == block PNG byte-for-byte
   (19/19). A03 §2 measured `grass_ground1/2/3` as the "bright diagonal vein lattice",
   "denser crosshatch veins; worst visual repeat", and a mirror of the same lattice (idx 14/15/16;
   F03/R02). `ground1` is a grey-brown cell with diagonal scratches and Sx=1.40 (F06); `grass2`
   has FFT-aniso 5.16 (F04). These are visible RGB sampled at shader `:392`, then multiplied at
   `:427`. Applying any height input cannot remove detail that lives in the sampled albedo.
2. **The crossfade adds a second, repeating pattern [O]/[D].** A02 Q1/Q2: `dir=id mod 4`,
   `variant=(id div 4) mod 4`, `half=(id div 16) mod 2`, `opposite=(id div 64) mod 2` (shader
   `:365-378`) give only 32 patch roles for 124 ids: the same dark-edge/lobe shape is stamped on
   every cell with that id, unconditionally (`:417`,`:427`), with no neighbour/direction input
   (A02-E7). A02 §2 counts **8 ids mapped to the constant-0 sentinel** → `rgb = 0 + v_specular`
   at `:427` (black cells / cliff faces, B01's guard). This is a *visible albedo darkening*, not
   a height read.
3. **The repeat scale and filtering amplify both [O]/[I].** `uv_repeat=(0.5,0.5)` → one cell per
   2 m with world-XZ texgen (shader `:214-218`,`:392`; A03 E06), and the atlas has
   `mipmaps/generate=false` (A03 E07). Nearest/minified sampling of a 2 m verbatim repeat is the
   classic aliasing path for "faint diagonal streaks / repeating bands" (A03 F09; CHARTER §2
   items 1 and 3).
4. **The vein art is a large share of the frame [O, pre-B03].** G15 §2 decoded tileblocks show
   `grass_ground1` (id 14) at **27.87%**, `grass_ground3` (id 16) at **15.59%**, `test8` (79)
   7.49%, `test7` (78) 6.53%, `grass1` (0) 15.62% — i.e. the two loudest lattice arts cover about
   **43.5%** of cells in the available dumps. **[U]** B03's redirect of `grass_ground1/2/3` is
   present in code but no post-B03 capture exists (G15 §0/§3); the current frame's exact mix is
   therefore UNVERIFIED, but nothing about the height chain would change *which art is sampled*.
5. **Height's actual visual role is different and already implemented [O].** Height selects
   shore/cliff families and face modes (`world3d_terrain.gd:1413-1487`; A08 §4) and displaces
   vertices (`:1392`). A05 confirms relief *is* generated but reads flat due to amplitude-vs-
   footprint scale and gates, not because a height layer is displayed as colour. Feeding a mask
   into height would alter promotion, not remove vein albedo.

**Conclusion [I]:** the patterns are fully explainable by (1)+(2)+(3) on the visible path. No
height-only layer is needed to explain them, and none is mis-bound as albedo. This is what
**refutes** the hypothesis as stated.

---

## 5. What would change in the render if the hypothesis were applied

Assume the "pattern layer" is taken off albedo and routed to the height input (the literal
owner proposal). Consequences, with the three ticket risks called out explicitly:

### 5.1 Loss of donor tile identity — HIGH RISK [D]/[I]
- The albedo would stop being `tile_rgb(v_tile, …)` (shader `:329-338,392`) and become a
  single/ramp surface. The port's donor-grounded representation — 124-name tile dictionary,
  118 smoothing rules, detail-bitmap pass (`game.gd:1903-1952`), `tileblock` → `UV2.x`
  (`world3d_terrain.gd:1053-1075`) — would become visually invisible (A08 §1, §6).
- A03 F02 measured that no cell in the grass family supplies donor-scale mottling
  (LF 0.09–0.25; between-cell RGB std only (5.6, 8.8, 3.5)). A height ramp substitute would
  produce a smooth gradient, **not** the donor's soft multi-metre mottling. The field would get
  flatter — exactly the charter's complaint (CHARTER §1 line 21) — not closer to the samples.
- Cliff/shore identities (`sandsea1/5/6`, `rock4/rock8`, `rockNvf/vs`, A08 §1.3/§4) are selected
  by height in GDScript; overwriting `height[]` with mask intensities would **reselect those
  families unpredictably** (mask bytes are not metres), potentially removing real cliff art or
  inventing grey faces.

### 5.2 Breaking the published `mask_to_alpha` A/B — HIGH RISK [O]/[D]
- The A/B contract (shader `:484-496`; A02-E10/E11; binding deliberately left at 1.0 in
  `world3d_terrain.gd:744-751`) depends on `a` existing at `:427`:
  `rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular`. If the alpha atlas is removed from
  albedo, `mix(1.0,a,x)` has no visible `a` to gate — the uniform becomes a **no-op**, and A02's
  diagnostic `mask_to_alpha=0` partition test (A02 P3, recommendation 1) can no longer separate
  mask share from atlas/palette share.
- B01's constant-0 sentinel guard (shader `:410-419`, A02-P1) and the A02-P4 contrast compression
  (`:418-419`) both operate on that same `a`; routing the layer away voids those fixes and the
  black-cliff-face analysis built on them.
- The donor's mask is a *visible crossfade weight* (A08 §2, `bmTransparency`), so hiding it is a
  **departure** from donor structure, not a step toward it. No donor-parity claim can attach.

### 5.3 Breaking mesh invariants — HIGH RISK [O]/[D]
- `height[]` is a per-cell `PackedFloat32Array` of length `w*h`, decoded from base64
  (`world3d_terrain.gd:1310-1322`), baked into vertex Y at `:1392`, differentiated into normals
  at `:981-996`, read by face promotion at `:1413-1487`, and bound to water at `:1179`. A texture
  sampled in `fragment()` **cannot move geometry** — it would add a second, inconsistent height
  source with no effect on the mesh.
- Resolution mismatch: the candidate images are 512×256 (`alpha.png`), 1024×512
  (`alphavert.png`), 320×320 (detail bitmaps) or arbitrary (terrainmask TGA), while the mesh grid
  is w×h cell centres (e.g. 64²/240²/320²). Re-sampling into `height[]` is a **PORT APPROX**, not
  donor parity, and would break the invariant "`height_at_world()` samples the same grid the mesh
  was built from" (`world3d_terrain.gd:1846-1851`).
- Relief stamping (`apply_relief_grid()`, `:507-541`) clamps to the donor band ±2.964 and expects
  a w×h float array; feeding bitmap intensities would violate that band unless re-scaled with an
  invented constant (forbidden: A08 §7 #5, "no invented donor constants").
- One-uint8-tile-id-per-cell in `UV2.x` (`:1053-1075`; A03 E04) and one vertex per cell centre
  (`:1369`, A02-E9) must stay intact; a per-pixel height layer does not replace either contract.

### 5.4 Other risks [I]
- No synthetic dither/noise replacement is allowed (CHARTER §3 decision S-25-09; A08 §7 #2); a
  height ramp cannot legally be "beautified" with a noise field to mimic donor mottling.
- The change targets the wrong variable: after it, the 2 m verbatim repeat, the `id mod 32` patch
  reuse, the no-mip aliasing and the vein art are all still present on the visible path.

---

## 6. What actually addresses the patterns (proposals, no edits made)

These route to the visible path and are consistent with the evidence; all are **PORT APPROX**
or measured-derivation, not donor parity:

1. **Stop tiling the loudest cells as generic ground**: blacklist `grass_ground1/2/3` and
   `grass2` as repeating meadow; prefer isotropic `grass9/test9/test8` (A03 R01/R02/R03). Gate
   `ground1` to road/mine masks only (R05). G15's histogram shows this is a high-coverage lever.
2. **Neutralise the sentinel and compress mask weight**: guard the constant-0 patches (A02-P1)
   and reduce mask contrast (A02-P4) — both keep the donor-grounded patch geometry intact.
3. **Partition the cause first**: produce the sanctioned `mask_to_alpha=0` A/B (A02-P3) at an
   identical camera. This is only meaningful while the layer stays on albedo — another reason the
   height reroute would destroy the experiment.
4. **Large-scale variation is a tile-id/relief/decal problem** (A03 F02/R09; A08 §3), not an
   albedo-height problem: route it to relief props / active donor grids (G07/A05), never to a
   noise field.

---

## 7. UNVERIFIED register (do not promote)

1. No donor GPU A/B frame exists; every visual statement above is code/pixel structural, never
   proven donor parity (CHARTER §3; A08 §8.10).
2. The exact tile-id → alpha-patch rule, `bmTransparency` pass count, eye-plane values and donor
   metres-per-cell remain CONFIRMED_UNVERIFIED / PORT APPROX (A08 §8; A02 §0).
3. Which cell mix dominates the **current post-B03** frame — no live capture; G15's 43.5%
   `grass_ground1/3` figure is from pre-B03 dumps (G15 §0/§3).
4. Whether mask share or atlas-repeat share dominates the streaks — needs the `mask_to_alpha`
   A/B, which does not exist (A02-E11).
5. The exact causal share between aliasing and cell repetition was not measured with a GPU
   (A03 F09).

---

## 8. Agreement / disagreement with H03

**Not assessable at write time — no H03 conclusion was available.** After forming and writing
the verdict above, a repo-wide check (`docs/terrain_swarm_2026-11-25/reports/` listing and a
`**/H03*` glob) found **no H03 file** (nor H01/H02/H04). Per the ticket, H03 was deliberately
not read before the verdict; since it does not yet exist on disk, no agreement/disagreement
statement can honestly be made. If H03 lands later, the comparison should be appended here by
COORD or a follow-up: the specific point of comparison is whether H03 also finds that the
pattern-producing layers are the visible atlas art + alpha crossfade (A03 F03/F09, A02 Q1/Q2)
rather than a mis-bound height/selection layer (§3/§4 of this report). This H05 verdict remains
**REFUTED** regardless of that comparison, because it is grounded in the cited code and pixels,
not in H03.

---

*End of H05. One report written. No code, asset, config, test, git or runner state changed. No
donor-parity claim.*
