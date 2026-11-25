---
id: H03
ticket: "TERRAIN-SWARM-WAVE-G / H03 — decisive test of the owner's heightmap-layer hypothesis"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GODOT_JOB
scope: "Exactly one report written. No shader/script/asset/config/test/git edit; no Godot launch; no runner job. Donor files read READ-ONLY by byte/Pillow-style probes only — nothing copied, executed or rendered."
owner_file: docs/terrain_swarm_2026-11-25/reports/H03_heightmap_hypothesis.md
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
parity_guard: "No donor GPU A/B frame exists in this session. No donor-parity claim is made. All donor facts are structural (file bytes / plaintext), all port facts are code reads; every visual attribution is INFERRED."
evidence_ids: [H03-E1..H03-E14]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# H03 — Is a pattern-producing terrain layer really a height source drawn as albedo?

## 0. Mandate, stance and honesty labels

Owner hypothesis (WAVE_G_CHARTER.md:106-124): *"We need to understand how to use heightmap — one
of the terrain layers, the one that produces strange patterns, should not be visible but used for
heightmap only."*

The charter explicitly says this is a **hypothesis, not a fact** and must be tested, not assumed.
This report tests the four candidates named in the dispatch. It does **not** try to make the
hypothesis true.

**Test standard used.** For the hypothesis to be CONFIRMED for a layer, two independent things must
both hold:

1. **Donor role = height/data**, not albedo (proved from donor plaintext/bytes or the A08
   consolidation); **and**
2. **Port draws that layer as visible albedo** (proved from a shader sampler/binding and a
   fragment write), i.e. it is mis-routed.

If (1) is true but (2) false, the layer is already height-only → the hypothesis does not explain
the patterns **in this layer**. If (2) is true but (1) false, the layer is genuinely visible in
donor too → the "should be heightmap" framing is unfounded. A clear verdict is given for each
candidate, including partial verdicts where the two halves disagree.

Label key: **[O]** observed (literal code line, file byte, or a number measured in this task);
**[D]** derived (arithmetic/control-flow consequence of [O]); **[I]** inference without a
pixel-aligned donor A/B; **[U]** UNVERIFIED.

**Line-number drift note [O].** The dispatch says the alpha mask is "sampled at :419 and folded
into RGB at :427". `:427` is still the fold in the current tree. The flat-mask *sample* has moved
to `:417` after A06-F2; current `:419` is the A02-P4 contrast-compression line. Both are quoted
below so the evidence is unambiguous.

### Evidence register

| ID | Evidence | Label |
|---|---|---|
| **H03-E1** | Shader `:60` `tile_atlas`, `:66` `alpha_atlas`, `:72` `alphavert_atlas`, `:83` `shadow_map` — the **only** terrain samplers; no height/relief/mask-TGA sampler exists. | [O] |
| **H03-E2** | Flat mask `a = texture(alpha_atlas, alpha_patch_uv(v_tile, fract(v_alpha_uv))).a` at `:417`; face mask `a = texture(alphavert_atlas, mask_uv).a` at `:407`. Both read `.a` intensity only. | [O] |
| **H03-E3** | `:427` `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular`; `mask_to_alpha = 1.0` at `:235`; `ALPHA = 1.0` at `:475`. The mask modulates **albedo**, not transparency. | [O] |
| **H03-E4** | `:419` `a = mix(mix(1.0, clamp(a, 0.35, 1.0), 0.5), 1.0, step(2.5, scol) * step(2.5, srow))` — A02-P4 contrast compression + A02-P1 sentinel guard, both landed. Current mask amplitude is reduced but the RGB fold remains. | [O] |
| **H03-E5** | A08 §2: donor `reftile.mat:6` `Texture2Name = alpha`, `:17` `BlendingMode = bmTransparency`; `hf.pvl.smx3.frag:13-14` reads `color.rgb` from texUnit0 and `color.a` from texUnit1; "supplies **mask intensity only**; it is **not a colour layer, a height ramp, a distance field, or a noise source**"; alphanull = "no transition". | [O, cited] |
| **H03-E6** | A02 §1 Q2 / E2/E10: port samples one 64² patch unconditionally on every fragment of every flat cell, with no boundary test; donor mask is a crossfade weight at block boundaries over a second base pass. A02 §2: 8/124 ids map to the constant-0 sentinel patches → `a=0` → black cells (now mitigated by H03-E4). | [O/D, cited] |
| **H03-E7** | A06 §3.3: pre-A06-F2 vertex-stage `fract()` made the mask a per-cell scalar → "soft blocky patches" and "repeated dark blotches"; current `:417` moves `fract()` to fragment stage, restoring intra-cell variation. A01 Rank 3 lists the same mask→RGB co-registered grating. | [O/D, cited] |
| **H03-E8** | Donor read-only listing: `data/terrain/tiles/textures/grass_ground1.dds` exists as a tile-texture block; the detail bitmaps are **separate files** `data/gen/bitmap/ext/tile_lowground.bmp` and `tile_highground.bmp`; `data/terrain/tiles/textures/alpha.bmp` / `alphanull.bmp` separate again. | [O] |
| **H03-E9** | A03 E01/E08/F03: atlas cells are byte-identical copies of `blocks/*.png`; `grass_ground1/2/3` are cells idx 14/15/16 with a bright diagonal vein lattice (idx16 = exact mirror of idx14), LF 0.39 for idx15 — intrinsic albedo art, not a mask/selection image. | [O, cited] |
| **H03-E10** | `game.gd:1903-1952` `_apply_detail_pass` loads `structs/tile_lowground.png` / `tile_highground.png`; picks by `h < 0.1`; `tex = int(pixel.r * 255) / 2` (`:1935`) and writes `tileblock[i] = tex` (`:1952`) only where the id is still `grass1`. B03 re-rolls the two ids test7/test8 (`:1943-1950`). The detail bitmap's **R value selects a tile id** and is never drawn as an image. | [O] |
| **H03-E11** | `game.gd:1596-1617` grass_ground1/2/3 appear as named entries in `DONOR_SMOOTH_RULES` (Item 4/5/6 J=3 `0.64/0.0028/0.36`, cfg:447/568/677/798; Item 8 J=2): they are tile ids chosen by 3-pass smoothing and then drawn as albedo. `game.gd:2191-2196` (B03-P3) redirects their *art* to grass9/test8/test7 in the live path. | [O] |
| **H03-E12** | `import_donor_masks.py:4-9,108` terrainmask TGA **R = relief, G = forest/stone, B = water, white = start**; gauss masks carry water only (R/G zero except starts); RGB is copied "so the format stays identical", i.e. for format fidelity, not for display. Donor read-only: 230 `data/gen/terrainmasks/land/*_gauss.tga` files exist. | [O] |
| **H03-E13** | `mapgen.gd:166,180` loads the mask PNG via `ResourceLoader` and reads it with `get_image()` (CPU read, never bound to a shader); `:198-215` averages R/G/B per cell and computes `height[i] = -1.1*(cb/255)*(1+(cr/255)*3.5) + relief(cr)` at `:212-213`, `relief_smooth[i]` at `:214`, `forest[i]=cg/255` at `:215`. `world3d_terrain.gd:1310-1312` writes `vertex.y = height[i] * HEIGHT_SCALE`. | [O] |
| **H03-E14** | Donor read-only byte probe: `data/pattern/k_ravine_big_stone_1.pattern` = `w=84,h=100`, `len=477326`; a float32 grid at byte offset **8225** has min **−2.9631**, max **≈0.0066** (matches A08 §4 / DPATTERN-01:152). `donor_gen.py:74-85` parses only the occupancy-byte mask from `.pattern`; `pattern_gen.gd:66-95` Stamp carries `cells`/`kind` for placement; `game.gd:84-123,974-984,1039-1102` writes **height only** from the two decoded grids. A05 §4 cross-check: "No path writes pale colour from a height stamp … S5:427 gets RGB from the atlas." | [O] |

---

## 1. Candidate-by-candidate verdicts

### C1 — alpha / alphavert mask patches (`:417`/`:419` sampled, `:427` folded into RGB)

**VERDICT: CONFIRMED for "the port wrongly VISUALISES a mask"; REFUTED for "this layer is a height
source that should be heightmap-only".**

- **[O]** The port samples mask **intensity** (`.a`) at `:407` (alphavert, faces 1/2) and `:417`
  (alpha, flat), then writes it into **albedo** at `:427` with the shipped default
  `mask_to_alpha = 1.0` (`:235`); framebuffer alpha is forced to 1.0 (`:475`). The mask is
  therefore **visible as per-cell darkening** — exactly the "should not be visible" part of the
  owner's intuition. (H03-E2/E3)
- **[O, cited]** Donor does the opposite: the second sampler supplies mask intensity only, and
  `bmTransparency` composites it as a **crossfade weight over a second base-tile pass**
  (`reftile.mat:6,17`; `hf.pvl.smx3.frag:13-14`; A08 §2). A08 §2 states verbatim that it is **not a
  height ramp, not a colour layer**. (H03-E5)
- **[O/D]** The port additionally samples a full 64² patch on *every* flat fragment with no
  boundary test, instead of only at tile transitions, and folds the donor's "no transition"
  sentinel patches (constant 255) and "full cut" patches (constant 0) into albedo; A02 measured 8
  ids at `a=0` → black cells/cliff faces. A06 showed the pre-F2 vertex-stage `fract()` collapsed the
  patch to a per-cell scalar, producing "soft blocky patches" and "repeated dark blotches" on the
  2 m grid. (H03-E6/E7)
- **[D]** So the heightmap route is **not donor-grounded for this layer**. The donor-correct role
  is a *blend/transparency* weight between two albedo passes; the port's defect is an **albedo
  fold of a transparency mask**, not a missing height binding. The currently landed A02-P1/P4 and
  A06-F2 mitigations (`:410-419`) compress the mask to `0.35..1.0` at 50 % strength and neutralise
  the zero sentinels; the structural fold at `:427` still exists. **[U]** how much visible pattern
  remains after those mitigations — no post-fix `mask_to_alpha=0` A/B frame exists (A02-E11).

**Conclusion:** this is the only candidate where *any* part of the owner's hypothesis holds, and
even here the "heightmap only" half is refuted.

### C2 — grass_ground1/2/3 vein-lattice tile art

**VERDICT: REFUTED.**

- **[O]** The vein lattice is the block art itself: A03 measured cells idx 14/15/16 as byte-identical
  copies of `blocks/*.png`, with bright diagonal veins, a crosshatch LF of 0.39 for idx15, and idx16
  an exact mirror of idx14. It is albedo *by construction*, not a selection/height image. (H03-E9)
- **[O]** Donor keeps the two roles in separate files: `terrain/tiles/textures/grass_ground1.dds` is
  a tile block; `gen/bitmap/ext/tile_lowground.bmp` / `tile_highground.bmp` are the detail bitmaps.
  The donor detail pass (`loadtextureterrainfrombitmap.inc:4,8-9,25-41`; A08 §1.2) reads the bitmap
  R byte, `tex = floor(r*255) div 2`, and **selects tile ids** — the bitmap itself is never drawn.
  (H03-E8)
- **[O]** The port reproduces that: `_apply_detail_pass` reads R of `tile_lowground.png` /
  `tile_highground.png` and assigns a **tile id** to `tileblock[i]`; it does not sample the bitmap
  in the shader. grass_ground1/2/3 arrive through `DONOR_SMOOTH_RULES` (smoothing transition ids),
  not through the detail bitmaps, and are drawn as albedo — which is the donor-correct role for a
  named tile preset. (H03-E10/E11)
- **[D]** Therefore the premise "grass_ground1/2/3 are donor detail-bitmap output that donor only
  uses to select ids" is false. Moreover the live path now redirects their art to grass9/test8/test7
  (`game.gd:2191-2196`), so they are **not** the dominant painted cells in the current P0 frame.
- **[U]** Which cell actually dominates a given captured frame (A03 §7, no tile histogram on that
  PNG). The vein lattice is a real *visible* albedo pattern wherever those ids are painted, but it
  is not a misrouted height layer.

### C3 — height-map R channel (terrainmask TGA R = relief)

**VERDICT: REFUTED — it is already used as height and is not drawn anywhere as albedo.**

- **[O]** The terrainmask R channel is genuine height data: `import_donor_masks.py:4-9,108` and
  `mapgen.gd:1-6,63-85` document R = relief (255/191 plateau, 96/112 hill, 48/88 ravine,
  white = start). 230 real `_gauss.tga` masks exist in the donor (H03-E12).
- **[O]** In the port, the mask PNG is loaded on the **CPU** (`ResourceLoader.load` at `mapgen.gd:166`,
  `get_image()` at `:180`) and its R byte is decoded into `height[i]` at `:212-213` and
  `relief_smooth` at `:214`; the resulting height drives mesh vertex Y at
  `world3d_terrain.gd:1310-1312`. No shader sampler binds the mask PNG (only `tile_atlas`,
  `alpha_atlas`, `alphavert_atlas`, `shadow_map` exist — H03-E1/E13).
- **[O]** Even in the separate experimental heightmap path, `heightmap_world3d.gd:54-69` binds the
  splat as `albedo_texture` with `TRANSPARENCY_DISABLED`, and its own stats state "A = normalised
  height DATA (not opacity)" (`:14-15,252-253`) — height drives geometry/normals, not colour.
- **[O]** `heightmapwaves0.tga` is deliberately not bound (`water3d.gd:95-97`, A08 §8 item 8); the
  water `height_tex` uniform receives a 1×1 neutral fallback (`water3d.gd:209-210`), so no height
  texture is drawn as water colour either.
- **[D]** There is no layer here that is "wrongly visible": the R channel is consumed as height
  already. Its real defect is elsewhere — A05 §3.2 found the resulting amplitudes tiny
  (`+0.496 / −0.558` after RCODE-FIX-01) over footprint-scaled hundreds of metres, which makes
  terrain read flat. That is an amplitude/coverage problem, not a visibility misroute.

### C4 — relief pattern grids (donor `.pattern` float32 grids)

**VERDICT: REFUTED — they are already height sources (partially) and are never drawn as albedo.**

- **[O]** Read-only byte probe: `k_ravine_big_stone_1.pattern` is `84×100` and carries a float32
  height grid at offset 8225 with values in `[-2.9631, ≈0.0066]` — the same decoding A08 §4 /
  DPATTERN-01 report. These are authored relief data, not art. (H03-E14)
- **[O]** The port parses only the **occupancy** bytes from `.pattern` (`donor_gen.py:74-85`) and
  exports placement footprints to `donor_patterns.json`; `pattern_gen.gd:66-95` stamps carry
  `cells`/`kind` for forest/stone/hill/decor/mine/tile placement. The float32 grids are reduced to
  two 8×10 block-mean tables in `game.gd:84-123` and applied at `:974-984,1039-1057` by writing
  **`height[]` only**; the analytic fallback at `:1059-1102` likewise writes height only. (H03-E14)
- **[O, cited]** A05 §4 cross-check is explicit: "No path writes pale colour from a height stamp …
  S5:427 gets RGB from the atlas. Killing the marks will not add relief, and adding relief will not
  kill the marks." (H03-E14)
- **[D]** So the grids are not visible albedo and cannot be the source of the coloured/streaked
  patterns. Their actual defect is **under-use**, not wrong visibility: A05 §3.1/§3.6 found only
  **2 of 26** donor grids reach live height, and the donor-active `ravine_big` family has no port
  grid at all (the `k_ravine_1` producer is BLOCKED/RELIEF-02 and donor-disabled).

---

## 2. What is drawn vs what is data — consolidated

| Layer | Donor role | Port consumption | Drawn as visible albedo? | Height source? | Verdict |
|---|---|---|---|---|---|
| alpha / alphavert mask patches | Transparency crossfade over a 2nd base pass (`bmTransparency`), **not height** (A08 §2) | `.a` folded into RGB at `:427`, `mask_to_alpha=1` | **YES — wrongly** | NO (donor explicitly denies) | **C1: visualisation CONFIRMED / heightmap claim REFUTED** |
| grass_ground1/2/3 vein lattice | Named albedo tile preset (`terrain/tiles/textures/*.dds`) | atlas cell; smoothing-selected; now art-redirected | YES — correctly | NO | **C2: REFUTED** |
| terrainmask TGA R = relief | Height/class data | `mapgen.gd:212-214` → `height[]` → mesh Y | NO | YES (already) | **C3: REFUTED** |
| `.pattern` float32 relief grids | Authored height grids + object footprints | 2/26 decoded → `height[]` writes only | NO | YES (partially) | **C4: REFUTED** |
| atlas cell RGB (2 m `fract` repeat) | Repeated 1024² tile albedo, projected UVs | `:392` `tile_rgb(...)` → `:427` | YES — correctly, but verbatim 2 m repeat | NO | Not a height layer (A01 Rank 1 / A06 Rank 2) |

---

## 3. The single most likely layer the owner is sensing

**Answer: candidate C1 — the alpha / alphavert mask patches folded into RGB at `:427`.**

Reasoning, with the limits stated honestly:

1. **It is the only candidate that satisfies the observable half of the owner's intuition.** C1 is
   non-colour data in donor (a transparency weight, explicitly "not a colour layer, not a height
   ramp" — H03-E5) yet the port makes it *visible* as an albedo darkening factor (H03-E3). C2 is
   genuine albedo art, correctly drawn (and now redirected away); C3 and C4 are not drawn at all.
2. **Its measured visual signatures match "strange patterns".** A02 §3 ranks constant-0 sentinel
   cells, full-cell dark lobes on the 2 m `fract` grid, and `cell = f(id mod 32)` reuse as ranks
   1–3 of the *mask-driven* share; A06 §3.3 attributes the "soft blocky patches" and "repeated dark
   blotches" specifically to the per-cell mask scalar folded at `:427`; A01 Rank 3 lists the
   co-registered mask grating. The charter's "soft blocky patches / repeated dark blotches" is a
   better match to the mask than to any relief layer.
3. **But the owner's proposed mechanism is wrong for that layer.** Donor's mask is a **crossfade
   over a second albedo pass**, not a heightmap. Routing it to a height input would not restore
   donor behaviour; the donor-faithful direction is to stop treating it as a per-cell albedo
   multiplier (real two-pass crossfade, or remove the fold), which is an albedo/blend fix, not a
   heightmap fix. **[U]** whether the remaining mask contribution is dominant: A02-E11 records
   that the decisive `mask_to_alpha=0` A/B frame was never produced.
4. **The strongest single cause of the *streaks* is not any of the four candidates.** A01 Rank 1 /
   A06 Rank 2 attribute the faint diagonal streaks/repeating bands to the verbatim **2 m world-XZ
   RGB repeat** (`:214`, `:392`) under minification, with a measured ≈76 px horizontal period
   matching the predicted 73.7 px. That layer is honest albedo, not a height source. So the
   heightmap hypothesis does **not** explain the primary artifact either.

**Bottom line:** the layer the owner is most plausibly sensing is the **alpha-mask RGB fold (C1)**,
because it is real non-colour data wrongly made visible. The specific claim that it "should be used
for heightmap only" is **refuted** by donor evidence; no candidate layer is both a donor height
source and drawn as albedo in this port. Therefore the decisive test **does not confirm** the owner
hypothesis as stated.

---

## 4. Guardrails and UNVERIFIED register

- No donor-parity claim: no donor GPU A/B frame exists; every donor statement is structural
  (plaintext / byte decode) and every visual attribution is INFERRED.
- No code, shader, asset, config, test or git change; no Godot launch; no runner job submitted;
  exactly one file written (this report).
- No test weakened; no synthetic dither/noise field endorsed (CHARTER §3, S-25-09).
- **UNVERIFIED:** (a) the quantitative share of mask-driven vs atlas-repeat-driven patterns
  (needs the `mask_to_alpha=0` A/B at identical camera — A02-E11); (b) which atlas cell dominates the
  supplied P0 PNG (no tile histogram on that frame — A03 §7); (c) how much of the original mask
  artifact survives the landed A02-P1/P4 + A06-F2 mitigations (no post-fix A/B); (d) donor
  `bmTransparency` pass count / exact blend equation and the cell→patch rule (A08 §2,
  CONFIRMED_UNVERIFIED); (e) any claim that a heightmap route would change the visible streaks —
  no such frame exists, and no donor evidence supports the route.

*End of H03. One report written. No parity claim.*
