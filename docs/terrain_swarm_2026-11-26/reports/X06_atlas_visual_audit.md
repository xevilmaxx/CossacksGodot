---
id: X06
ticket: TERRAIN-SWARM-2026-11-26/X06
title: "Visual + byte audit of F05's 124-tile atlas mapping using converted port assets only"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_DONOR_READ__NO_REPO_EDIT_EXCEPT_THIS_REPORT__NO_GODOT_JOB
owner_file: "reports/X06_atlas_visual_audit.md (only repo file written)"
inputs_read: "variant3d/assets/terrain/{blocks/**,atlas/**,structs/presets_summer.json}; docs/terrain_swarm_2026-11-26/{CHARTER.md,SWARM_BOARD.md,reports/F05_tile_mapping.md,reports/F03_gen_config.md,reports/P06_prior_wave_distill.md,spec/06_TILE_AND_ATLAS.md}"
generated_outside_repo: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\atlas_audit\\"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
visual_parity_claim: false
---

# X06 — Visual validation of F05's 124-tile mapping (port assets only)

## 1. Executive summary

1. **[O] F05's structural mapping is confirmed on every checked axis.** The Summer
   manifest has 124 entries / 85 `DIRECT` + 36 `FACE_BASE_REUSE` + 3 `EMPTY`; all
   five claimed family ranges match their names with **zero mismatches** (rock base
   17–25, rock faces 53–70, sand base 26–34, sand faces 35–52, shore 93–98). The
   36 face cells are pixel-identical to their base cells; the 3 holes are exactly
   ids 86/110/123 (`alpha0a/b/c`). All 121 filled atlas cells are byte-identical
   to their declared source PNG (including 6 NEAREST-upscaled `sand1/2` cells),
   and all 121 declared `source_sha256` values match the on-disk bytes.
2. **[O] All three claimed art-duplicate groups verified by three independent
   passes** (file SHA-256, decoded pixel SHA-256, manifest `source_sha256`):
   `grass1 = test10 = test11` (ids **0/81/82**), `grass8 = test0` (ids **7/71**),
   and `test19 = winter23/24/25/26` (id **103** plus four unmapped winter blocks).
   112 block PNGs collapse to **105 distinct byte hashes** — no fourth group exists.
3. **[O] The `_winter` rename is one-for-one across all 124 indices**: 124/124
   aliases equal `summer_name + "_winter"`; both manifests keep index and name at
   the same slot. The only 3 source-art exceptions are the alpha sentinels
   86/110/123, where `winter_aliases.json` records `winter0/winter1/winter1` but
   both atlases keep the cells `EMPTY`. A separate **52-entry `kind` label collision**
   in the Winter manifest (51 `DIRECT`→`FACE_BASE_REUSE`, 1 `FACE_BASE_REUSE`→
   `DIRECT` at id 36) is a metadata defect, **not** a pixel or index defect.
4. **[D]/[I] The diagonal-vein lattice is real and is broad, not confined to one
   family.** FFT angular anisotropy over 112 blocks: **27 blocks ≥ 5**, **18 ≥ 10**.
   The strongest are rock art at ids 17–19/22–23 and their face copies 53–70
   (anisotropy 24.7–30.6); the specific tiles named in P06 §1B are ids
   **14 `grass_ground1` (6.28, FFT peak 145°)**, **15 `grass_ground2` (2.34,
   peak 5°)** and **16 `grass_ground3` (6.08, peak 35°, exact horizontal mirror of
   id 14)**. Visual crops confirm the bright diagonal crosshatch on 14/16 and the
   diagonal mottling on 15. Sand/shore/decal art also carries directional
   anisotropy (`sand1` 8.64, `sandsea1..4` 16.0–20.9, `desert5` 20.92), so a
   "vein-free" target cannot be reached by editing only ids 14–16.
5. **[I] Visually atypical but correctly named ids**: 24 `rock8` / 25 `rock9` read
   green-brown rather than grey rock (mean RGB 72.9/65.7/37.9 and 75.3/71.0/34.0
   vs 77.0/67.5/53.5 for `rock1`); 26/27 `sand1/2` read greenish and blocky
   (256²→1024² NEAREST, PORT APPROXIMATION); 10 `ground1` is off-palette grey-brown
   (99.8/90.7/66.3 vs grass ≈76/82/30), matching P06's independent observation.
   These are **art-content observations**, not evidence of a mis-mapped id; no
   donor frame was read, so no re-labelling is proposed.
6. **No donor file was read, no donor binary run, no GPU A/B frame exists. No visual
   parity is claimed.** Everything below is `[O]`/`[D]` over already-converted port
   assets, plus `[I]` visual interpretation.

## 2. Evidence table

| ID | Label | Evidence (port path / generated temp artefact) |
|---|---|---|
| E01 | **[O]** | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json`: `layout` 124 entries; `atlas` = 16384×8192 RGBA, 16×8 grid of 1024² cells, 128 slots, 124 named / 121 filled / 3 empty; kinds DIRECT 85, FACE_BASE_REUSE 36, EMPTY 3. `structs/presets_summer.json` = 124 names, index *i* ↔ cell `(i%16, i//16)`. |
| E02 | **[O]** | Same manifest: ids 86/110/123 `kind=EMPTY`, `source_png=null` (`alpha0a/b/c`); ids 35–52 + 53–70 `kind=FACE_BASE_REUSE`; ids 26/27 and four face copies carry `upscaled=true, source_size=[256,256]`. |
| E03 | **[D]** | 112 PNGs in `blocks/`; 105 distinct file SHA-256 and 105 distinct decoded-pixel SHA-256. Duplicate groups: `{grass1,test10,test11}`, `{grass8,test0}`, `{test19,winter23,winter24,winter25,winter26}`. |
| E04 | **[O]** | Manifest `source_sha256` vs freshly hashed file bytes: **0 mismatches / 121**. Atlas cell crop vs declared source PNG (NEAREST resize where `upscaled`): **121/121 exact**, max abs diff 0. |
| E05 | **[O]** | Family name/kind check with zero failures: 17–25 all `rock*` DIRECT (9); 53–70 all `rock*vf/vs` FACE (18); 26–34 all `sand*` DIRECT (9); 35–52 all `sand*f/s` FACE (18); 93–98 all `sandsea*` DIRECT (6). |
| E06 | **[O]** | 36/36 face cells have `source_png` equal to their computed base cell (35–52 → base 26–34; 53–70 → base 17–25) and equal decoded pixels. Base mapping formula derived from the manifest name order. |
| E07 | **[O]** | `winter_aliases.json` 124 entries: 124/124 `winter_alias == summer_name + "_winter"`; `shared_alpha=true` exactly at 86/110/123; `rules.index_preserving=true`; kinds WINTER_PNG 112 / DESERT_REUSE 12. `tile_index_atlas_winter.manifest.json` keeps index and name at the same slot for all 124. |
| E08 | **[O]/[D]** | Winter alias `source_png` vs Winter manifest `source_png` differs at **only** 86/110/123 (alias `winter0/winter1/winter1` vs manifest `null`); all other 121 agree and all alias PNGs exist on disk. Winter/Summer `kind` differs at **52** ids: 51 DIRECT→FACE_BASE_REUSE and id 36 `sand1s` FACE_BASE_REUSE→DIRECT; the alias dictionary labels all 52 `WINTER_PNG`, and each shares art with an earlier index — the label is being used for "shared art", not for a donor face variant. |
| E09 | **[D]** | FFT angular anisotropy (256² luminance, 10° bins, radii 4–80 cyc), 112 blocks: 27 ≥ 5, 18 ≥ 10. Top: `rock3` 30.62 (peak 95°), `rock1` 28.73 (5°), `rock2` 28.70 (95°), `rock6` 27.14 (135°), `rock7` 24.71 (45°); `desert5` 20.92 (135°), `sandsea4` 20.85 (135°); `grass_ground1` 6.28 (145°), `grass_ground3` 6.08 (35°), `grass_ground2` 2.34 (5°). Temp: `fft_all.json`, `fft_data.json`. |
| E10 | **[O]/[D]** | `grass_ground3.png == np.fliplr(grass_ground1.png)` **exactly** (max diff 0, also exact at 64²). Passes tried: identity (mean abs 21.01, max 190), flipLR (exact), flipUD (mean 21.46), flip180 (mean 21.07), 64² flipLR (exact). Confirms F05 E16 / P06 §1B. |
| E11 | **[D]/[O]** | Visual crops (temp sheets) show bright diagonal crosshatch on ids 14/16, diagonal dirt mottling on 15, directional striations on ids 17–19/22–23, and light, non-directional sand on ids 93–98. No cell image was fabricated or edited. |
| E12 | **[D]** | Structure tensor, **central differences** (staggered-grid-safe): `rock6` Jxy +72.76 / coherence 0.68, `rock7` Jxy −72.76 / coherence 0.68 — exact mirror symmetry restored. Earlier forward-difference pass gave +145.93 vs +0.97 and was **rejected after three passes** (forward, re-cropped forward, central). Temp: `corrected_st.json`. |

Generated artefacts (all outside the repo, `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\atlas_audit\`):
`contact_sheet_124.png` (16×8 labelled atlas-cell sheet), `focus_grass_dirt.png`,
`focus_vein_rock_sand.png`, `audit_data.json`, `fft_data.json`, `fft_all.json`,
`corrected_st.json`, and the read-only analysis scripts `audit.py`, `followup.py`,
`fft_check.py`, `fft_all.py`, `kind_check.py`, `corrected_st.py`.

## 3. Method

1. **Sources.** Only already-converted port files were opened:
   `variant3d/assets/terrain/atlas/tile_index_atlas.png` (+ manifest),
   `tile_index_atlas_winter.manifest.json`, `winter_aliases.json`,
   `variant3d/assets/terrain/structs/presets_summer.json`, and all 112
   `variant3d/assets/terrain/blocks/*.png`. No donor path was opened, no donor
   executable run, no repo asset/source/config/git state touched, no Godot job
   submitted.
2. **PIL pass discipline.** Pass 1: `sys.path.insert(..., variant3d/tools/blender_py/PIL)`
   → `ImportError: cannot import name '_imaging' from 'PIL'` (vendored folder is a
   source-only stub: `blender_py/PIL/Image.py` + `pillow-13.0.0.dist-info`, no
   compiled extension). Pass 2: system Pillow **12.1.1** from
   `C:\Users\Maxym.Oboyshev\AppData\Roaming\Python\Python314\site-packages` →
   works. NumPy 2.4.3 used for statistics. This is recorded, not hidden.
3. **Contact sheet.** The real atlas PNG was opened once (decompression-bomb guard
   disabled for the known 16384×8192 image), each of the 124 `cell_px` rects
   cropped, LANCZOS-reduced to 128², and pasted into a labelled 16×8 grid with
   `id | donor name | kind`; EMPTY cells drawn as hatched placeholders. Two
   extra 256² focus sheets were built **from the block PNGs** for art-level
   inspection.
4. **Quantitative checks.** (a) SHA-256 over file bytes; (b) SHA-256 over
   `np.asarray(Image.open(...).convert("RGB")).tobytes()`; (c) manifest-declared
   SHA; (d) crop-vs-source pixel equality; (e) 18-bin FFT angular power
   anisotropy; (f) low-frequency power fraction (r ≤ 8 / r ≤ 128); (g) luminance
   structure tensor and mean RGB. Every claimed identity was re-read with a
   second instrument before acceptance, per charter §4 "multiple passes".
5. **Labels.** `[O]` = byte/text observed; `[D]` = computed from observed bytes;
   `[I]` = visual interpretation of the converted art; `[U]` = not verifiable
   from port-only evidence. **PORT APPROXIMATION** marks port-side deviations
   from donor intent. No donor-parity claim.

## 4. Findings

### F1 — The 124-cell grid, family ranges, face cells and holes are exactly as F05 says. `[O]`/`[D]`
Counts and zero-failure family checks are in E01/E05/E06. The labelled contact
sheet `contact_sheet_124.png` shows the expected order visually: grass 0–9,
transitions 10–16, rock 17–25, sand 26–34, sand faces 35–52, rock faces 53–70,
test/detail blocks, alpha holes 86/110/123, sand-rock 87–92, shore 93–98,
desert 111–122. **No id is visually swapped with another family block.** The
face cells look identical to their bases — which is exactly the manifest's
`FACE_BASE_REUSE` claim and exactly the port deviation F05 G2 describes
(25° tilt and `alphavert` projection absent) — **PORT APPROXIMATION**.

### F2 — Pixel identity of the duplicate-art groups is confirmed three ways. `[O]`/`[D]`
| Claim | Ids | File SHA | Pixel SHA | Manifest SHA | Verdict |
|---|---|---|---|---|---|
| `grass1 = test10 = test11` | 0, 81, 82 | identical | identical | all three match declared | **confirmed** |
| `grass8 = test0` | 7, 71 | identical | identical | both match declared | **confirmed** |
| `test19 = winter23/24/25/26` | 103 + 4 unmapped blocks | identical | identical | id 103 matches declared | **confirmed** |

105 distinct hashes over 112 files means the remaining 107 ids have unique art;
F05 §6/G6's "124 ids overstate distinct art" stands. The semantic difference of
`test10`/`test11` (16×16 vs 32×32 sub-tiling, `tiles.lib:328–339` per F05) is
**not** in the pixels — **[U]** engine-side.

### F3 — Winter rename is index-preserving; two metadata anomalies are isolated. `[O]`/`[D]`
124/124 alias names carry `_winter` at the same index (E07). The three sentinel
differences (E08) are consistent with F05 G1/F06 §5: the alias dictionary keeps
the hypothetical winter art while both atlases keep transparent holes — the
semantic gap is a **PORT APPROXIMATION**, not an index error. The 52 Winter
`kind` mismatches are a **label collision**: the Winter builder reused
`FACE_BASE_REUSE` to mean "this winter PNG already appeared at an earlier id"
(verified: each mismatched id shares its `source_png` with an earlier index;
alias dictionary calls all of them `WINTER_PNG`). This can mislead any consumer
that treats `FACE_BASE_REUSE` as "25° donor face variant" — a real QA hazard
even though rendering pixels are unaffected.

### F4 — The diagonal-vein lattice is intrinsic albedo, and it is not confined to ids 14–16. `[D]`/`[I]`
| Id(s) | Block | FFT aniso (peak°) | Visual character | Label |
|---:|---|---:|---|---|
| 17/53/54 | `rock1.png` | 28.73 (5) | near-vertical layered striations | `[O]`/`[I]` |
| 18/55/56 | `rock2.png` | 28.70 (95) | near-horizontal layered striations | `[O]`/`[I]` |
| 19/57/58 | `rock3.png` | 30.62 (95) | diagonal striations | `[O]`/`[I]` |
| 22/63/64 | `rock6.png` | 27.14 (135) | strong diagonal striations; coh 0.68 | `[O]`/`[I]` |
| 23/65/66 | `rock7.png` | 24.71 (45) | exact horizontal mirror of `rock6`; coh 0.68 | `[O]`/`[D]` |
| 21/61/62 | `rock5.png` | 5.97 (95) | directional rock striations | `[I]` |
| **14** | `grass_ground1.png` | **6.28 (145)** | bright diagonal dirt-vein crosshatch | `[O]`/`[I]` |
| **15** | `grass_ground2.png` | **2.34 (5)** | diagonal dirt mottling; LF 0.3104 | `[O]`/`[I]` |
| **16** | `grass_ground3.png` | **6.08 (35)** | exact horizontal mirror of id 14 | `[O]`/`[D]` |
| 11/12/13 | `grass_sand1/2`, `grass_rock1` | 4.59 / — / — | diagonal branch-like veins | `[I]` |
| 26/35/36 | `sand1.png` | 8.64 (105) | greenish, NEAREST-upscaled 256² | `[I]` PORT APPROX |
| 93–98 | `sandsea1..6.png` | 16.0 / 16.05 / 16.89 / 20.85 / — / — | light directional sand ripples | `[O]`/`[I]` |
| 112–115 | `desert2..5.png` | 20.27 / 20.28 / 17.49 / 20.92 | directional desert striations | `[O]`/`[I]` |

27/112 blocks have anisotropy ≥ 5 and 18/112 ≥ 10; the rock family alone supplies
five of the top five entries. P06 §1B's statement that the veins are *intrinsic
albedo* is therefore corroborated at pixel level, and its specific attribution
to `grass_ground1/2/3` is confirmed — but a fix limited to ids 14–16 would leave
rock, sand and shore anisotropy untouched. **[I]** Any rendered lattice is a
product of these albedo cells plus the port's 2 m repeat (`P06 §1B`); no runtime
capture or donor frame was examined here, so this is **not** a claim about the
current GPU image.

**Methodological caution recorded (multiple passes).** A forward-difference
structure tensor first reported `rock6` coherence 0.6856 / Jxy +145.93 but
`rock7` coherence 0.0093 / Jxy +0.97 — apparently contradictory for two exact
mirrors. Pass 2 re-cropped the gradient grids (no change); pass 3 used central
differences on matched pixel centres and restored symmetry exactly
(Jxy ±72.76, coherence 0.68 for both). The forward-difference reading was
**rejected**; FFT anisotropy and visual crops agree with the central-difference
result. This is why the report ranks tiles by FFT anisotropy rather than by the
first-pass tensor.

### F5 — Visually atypical ids: art-content flags, not mapping errors. `[I]`
- **24 `rock8`, 25 `rock9`** (and their face copies 67/68, 69/70) read
  olive/green-brown, unlike the grey-brown layered rock of 17–23. Mean RGB
  (72.9/65.7/37.9) and (75.3/71.0/34.0) vs `rock1` (77.0/67.5/53.5). F05 E08
  assigns `rock8` to `abs(h)>2.7` — a high-altitude override — so dark/mossy art
  may be authored intent. **[I]**, do not re-map without a donor frame.
- **26 `sand1`, 27 `sand2`** read greenish and visibly blocky in the 256² focus
  sheet; manifest declares `upscaled=true` from 256² donor art via NEAREST.
  This is the documented **PORT APPROXIMATION** F05 G3, now visually confirmed;
  all six affected atlas cells are pixel-exact to the upscaled source (E04).
- **10 `ground1`** is grey-brown/off-palette (99.8/90.7/66.3, FFT aniso 1.53),
  independently flagged as off-palette in P06 §1B. F03 `texturemap.inc:627–636`
  makes it the road/dirt tile; its look is consistent with that role, so this is
  a **palette observation**, not a mislabel.
- **103 `test19`** is byte-identical to `winter23..26` yet reads green, not snowy
  (F05 G6/F05 §3). The alias dictionary marks those four winter PNGs
  deliberately unmapped; no contradiction, but a naming trap for QA.

### F6 — No visual contradiction in the family ranges themselves. `[O]`/`[I]`
Every one of the 124 labelled cells was inspected on `contact_sheet_124.png`.
Rock cells 17–25 *and* their face copies 53–70 all show rock strata; sand 26–34
and faces 35–52 all show sand/soil; shore 93–98 all show light sand; grass and
desert blocks occupy the expected ids. The only cells that do not resemble
their family's dominant look are F5's flagged art-style cases, and none of them
has a mismatched name, kind or source hash. **F05's id → cell mapping is
internally self-consistent.**

### F7 — What the audit cannot establish. `[U]`
Whether any sampled runtime tile actually uses ids ≥ 86, whether the donor's
`AngleX/AngleZ=25` face projection would remove or worsen the visible
striations, and whether the observed anisotropy reproduces a donor frame are all
outside port-only evidence. See §7.

## 5. Implications for `spec/06_TILE_AND_ATLAS.md`

1. **§1–§3 confirmed without change** for: 124 ids, 124-cell 16×8 grid, index
   dictionary from `presets_summer.json`, 85/36/3 kind split, family ranges
   (cliff/rock 17–25 + 53–70; sand/shore 26–52 + 93–98), 36 identity face cells,
   3 EMPTY holes, the two named byte-identical groups, and the index-preserving
   `_winter` rename. This audit adds **E01–E12** as a port-side verification layer.
2. **§2 should gain a Winter-metadata caveat**: 52 `kind` flags in
   `tile_index_atlas_winter.manifest.json` use `FACE_BASE_REUSE` to mean shared
   seasonal art, not a donor face variant; id 36 is the single reverse case.
   Consumers must key on the integer id + name, not on that flag.
3. **§2/§4 should link the vein register** (F4 table): the "no diagonal vein
   lattice" acceptance target in CHARTER §6.4 / V15 cannot be met by patching
   ids 14–16 alone; rock 17–23 (+ face copies 53–70), sand 26/27 and sandsea
   93–97 / desert 112–115 carry comparable or stronger anisotropy in the shipped
   albedo. This is a **`PORT APPROXIMATION` risk register**, not evidence of a
   donor defect — the donor art may legitimately be directional; no donor frame
   was read.
4. **§5 (alpha masks) stays as written**: this audit independently confirms that
   both atlases keep 86/110/123 empty while the alias dictionary carries winter
   art, i.e. F06's semantic hole remains unresolved.
5. **Keep the no-parity stance.** Every statement here is structural or CPU-side.
   A donor GPU A/B is still required before any "donor-faithful visual" wording.

## 6. Risks

| Risk | Evidence / label | Mitigation |
|---|---|---|
| Face cells "look correct" and hide the missing 25°/`alphavert` treatment. | E06, F1 `[O]` + PORT APPROX | Keep `FACE_BASE_REUSE` distinct ids; carry `AngleX/AngleZ` and projection as metadata; do not bake fake tilt. |
| Winter `kind` flag misread as a donor face variant. | E08, F3 `[O]`/`[D]` | Key on id/name; document the 52-entry collision before any consumer uses `kind`. |
| 3 EMPTY sentinels sampled by a future generator → transparent holes. | E02, F3 `[O]` | Sentinel-aware branch or explicit QA test; do not fabricate art. |
| "Fix the veins" by editing only `grass_ground1/2/3`. | F4, E09 `[D]`/`[I]` | Use the full anisotropy register; any change is a labelled PORT APPROXIMATION and needs a donor frame to judge. |
| Duplicate art counted as variety (105 unique / 112 files). | E03 `[O]`/`[D]` | Report distinct-art count beside id count; keep semantic sub-tiling as UNVERIFIED. |
| Contact-sheet thumbnails hide 1-pixel defects. | Method step 3 `[D]` | Pixel-exact crop comparisons (E04) cover all 121 filled cells at full 1024². |
| Forward-difference metric produced a false anomaly on mirrors. | E12 `[D]` | Central differences + FFT + visual triple check; rejected pass recorded. |

## 7. UNVERIFIED register (do not promote)

1. **[U]** Runtime activity of `texturemap.inc` id-selection rules (commented per
   F05 E08/F07) and of `tilesmooth*.cfg` consumers (F03 F15) — this audit did not
   read donor text.
2. **[U]** Whether any shipped or captured map samples ids ≥ 86 (F05 E15 reports a
   31-id capture capped at 85; not re-checked here).
3. **[U]** How the donor applies `AngleX/AngleZ=25` to `vf/vs/f/s` ids and whether
   `alphavert` would change the visible striations — no donor frame/decompile here.
4. **[U]** Whether the FFT-anisotropic albedo matches donor appearance; the donor
   art exists but no donor GPU frame exists, so **no parity claim**.
5. **[U]** Engine-side `test10/test11` 16×16/32×32 sub-tiling and `tsDouble` /
   `ttExtended` packing; not in PNG bytes.
6. **[U]** Whether the Winter `kind` collision affects any actual consumer; only
   manifest contents were inspected, no runtime trace.
7. **[U]** The vendored `variant3d/tools/blender_py/PIL` has no compiled `_imaging`;
   whether it works inside Blender's own Python is outside this task.

## 8. Open questions

1. Should COORD amend spec §06 §2 with the 52-entry Winter `kind` collision and
   the F4 vein register, or keep this report as the annex?
2. If the owner wants the lattice removed, which is authoritative: donor-directed
   re-authoring of the flagged albedo, or port-only smoothing/UV rotation? Both
   are PORT APPROXIMATION until a donor A/B exists.
3. Should the 3 EMPTY cells be filled with `grass1.png` + `alphanull` semantics,
   or stay transparent with a guard? F06 §5 and F05 G1 still disagree on intent.
4. Are ids 24/25 (`rock8`/`rock9`) intentionally mossy at high altitude, or are
   they the wrong DDS bound in `tiles.mat`? Requires a donor-file read by a
   donor-wave worker (F05 already cited `tiles.mat:594–601`).
5. Does any D08 binary-side finding recover a face-promotion rule that would
   explain why rock faces are reused as identity copies in the port?

---

*End of X06. One repo file written. No donor read/execute/copy; no Godot job; no
asset/source/config/test/git change; no donor visual-parity claim.*
