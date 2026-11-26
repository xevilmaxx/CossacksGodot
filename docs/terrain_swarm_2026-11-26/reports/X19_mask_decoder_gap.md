---
id: X19
swarm: TERRAIN-SWARM-2026-11-26
wave: X (verification / cross-check)
title: "X19 — donor mask truth vs the port's two mask decoders: exact gap, recipe and vectors"
ticket: X19
owner_file: reports/X19_mask_decoder_gap.md
status: LANDED__READ_ONLY__NO_CODE_EDIT__NO_ASSET_EDIT__NO_GODOT_JOB
created: 2026-11-26
donor_root: "C:\\Games\\Cossacks 3 (read-only; no donor binary executed, copied or committed)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:41,125). Nothing here is a donor-parity claim. Port statements are port-internal measurements or PORT APPROXIMATION."
method: "Read-only. Three passes: (P1) line-by-line read of the two port files; (P2) re-read of donor generatemap.inc/texturemap.inc GSC text and F04; (P3) in-memory Python/numpy re-decode of named donor TGAs (no script or asset written)."
---

# X19 — donor mask truth vs the port's two mask decoders

> **Label key.** **[O]** = literal file:line / donor byte / computed pixel statistic
> re-read this ticket. **[D]** = deterministic arithmetic on [O]. **[I]** = plausible
> reading without byte proof. **[U]** = UNVERIFIED. **PORT APPROXIMATION** = an
> explicitly labelled port substitute, never a donor claim. All donor paths are
> relative to `C:\Games\Cossacks 3\`; all repo paths to the workspace root.
> F04 donor truth is taken as authoritative for shipped pixels; no Godot job,
> no donor execution, no source/asset/config/test/git edit. Exactly one file
> written — this report.

## 0. Executive summary

1. **[O]** The "port mask decoder" is **two separate files with no shared contract**:
   `variant3d/tools/import_donor_masks.py` is a *pixel copier + manifest writer* (it
   never computes height), and `variant3d/scripts/mapgen.gd` is the *runtime sampler*
   that turns the copied PNG into height/forest/starts (`import_donor_masks.py:92-103`;
   `mapgen.gd:180-238`). Nothing decodes donor masks into the A03 shape
   (`masks/height/**/*.height.png` + labelled index, A03:276,296) — that path is
   **MISSING**.
2. **[O]** On the shipped data the core height rule is **already correct at 320²**:
   `h = -1.1*(B/255)` because R=0 off starts (`mapgen.gd:212-213`; F04 §6, §9:434;
   `generatemap.inc:567-574`). I re-measured R and G as exactly 0 on all non-start
   pixels of four named donor TGAs (P3). **No parity claim** — this is formula
   agreement on bytes, not an A/B frame.
3. **[O]/[D]** Four concrete defects were found. **BUG-1**: the manifest water
   heuristic uses `B > 58`, i.e. integer **B ≥ 59**, while `h < -0.25` means
   integer **B ≥ 58** (`import_donor_masks.py:98`; F04 §6,§9:432). Med/22 has 22
   pixels at B=58 → 0.213643 reported vs 0.213857 correct (P3). **BUG-2**: the same
   expression counts the white start pixels as water (`import_donor_masks.py:98`;
   donor zeroes starts at `generatemap.inc:440-443,565-566`). **BUG-3**: the port's
   "coastal" gate `height[i] < 0.8` (`mapgen.gd:126`) is **always true** because
   mask-only height ≤ 0, so all interior cells are smoothed, not just coastal ones;
   the donor gate is `gMapMask[*].water == cBWater` (B byte **=255**) with a radius-2
   neighbourhood (`generatemap.inc:621-637`; spec §05:19-28). **BUG-4** (config-level):
   the port's `land` category reads `terrainmasks/land` with up to 24 % water while
   the live donor Land shape is `nowater2` (`import_donor_masks.py:78`; F04 §9:438).
4. **[O]/PORT APPROXIMATION** Everything else that diverges is labelled in the port
   itself: `PER_TYPE=8` subsampling (56/1,331 = 4.2 %, zero DLC5)
   (`import_donor_masks.py:37,78-86`), 4-connected white-component starts instead of
   per-pixel detection (`import_donor_masks.py:45-63` vs `generatemap.inc:413-443`),
   farthest-pair start reduction (`mapgen.gd:102-115`), block averaging at 240²
   (`mapgen.gd:186-210` vs `generatemap.inc:541-543`), continuous `forest=G/255`
   (`mapgen.gd:215` vs the 5-class G enum at `generatemap.inc:473-485`), and an
   invented coastal kernel (`mapgen.gd:218-235`).
5. **[O]/[U]** A crucial donor nuance F04 did not spell out: there are **three
   different water notions** — (a) `water` **class** = B byte exactly 255
   (`generatemap.inc:486-490`), used for the coastal gate; (b) continuous water
   **bed** `h=-1.1*B/255`; (c) tile water/shore **tag** = `B>0 AND h<-0.25/-0.1`
   (`texturemap.inc:464-470`). The port collapses (a) and (c) into a height-only
   test. Also, the donor's second-pass sampler **comments out** `gMapMask.g := fg`
   (`generatemap.inc:545`), and every shipped `bsmooth` flag is false — so both
   donor `SmoothTerrain` stages are inert on vanilla masks; the fresh module must
   not invent relief from G or R.
6. **[U]** Forest/stone density derivation from G is **UNVERIFIED** as a runtime
   claim: G is 0 on every shipped non-start pixel (F04 §5.1), the G enum is text-only
   GSC intent, and native placement lives in patterns (`texturemap.inc:34`,
   D07/F08). No donor GPU A/B frame exists.

## 1. Evidence table

| # | Evidence (path:line) | What it establishes | Label |
|---|---|---|---|
| E1 | `variant3d/tools/import_donor_masks.py:5,7-9,108` | Docstring/manifest `note` state R=relief, G=forest-stone, B=water, white=start; "gauss variants only carry water (R/G zero except starts)"; RGB copied for format fidelity. | [O] port text (donor *intent* at `generatemap.inc:4-32`, not shipped pixels) |
| E2 | `import_donor_masks.py:31-37` | `donor_for()` → `data/gen/terrainmasks`; `OUT=.../assets/terrain/masks`; `PER_TYPE = 8` with comment "keep the asset set light". | [O] |
| E3 | `import_donor_masks.py:40-64` | `start_dots()`: pure-white mask at `:45`; BFS with **4** neighbours at `:56`; centroid normalised by source `w,h` at `:62-63`; comment "donor marks each start with a single pure-white pixel" at `:61`. | [O] |
| E4 | `import_donor_masks.py:78-86` | Seven hard-coded folders (`land, nowater2, mediterranean, peninsulas, islands, continents, continent`); glob `*pl*_gauss.tga` at `:81`; `step = len(files)//PER_TYPE`, `chosen = files[::step][:8]` at `:85-86`. No `.src`, no `.dlc5`. | [O] |
| E5 | `import_donor_masks.py:92-98` | `Image.open(...).convert("RGB")` at `:92`; `np.asarray` at `:93`; lossless PNG save at `:97`; `water = float((rgb[:,:,2] > 58).mean())` at `:98`. | [O] |
| E6 | `variant3d/scripts/mapgen.gd:25-30,63-85,87-94` | Constants `C_WATER=-1.1`, `C_PLATEAU=2.964`, `C_HILL=2.964/2.25`, `C_RAVINE=-2.964`, `WATER_DEEP=-0.25`, `WATER_SHORE=-0.1`; exact-code `relief()` and `relief_smooth()`; "no kernel invented" at `:87-91`. | [O] |
| E7 | `mapgen.gd:96-117` | Manifest starts → pixels at `:99-101`; **farthest pair only** for ≥2 starts at `:102-115`; invented 0.125/0.875 fallback at `:116-117`. | [O] |
| E8 | `mapgen.gd:119-143` | `_near_water()`: `height[i] < 0.8` at `:126`; radius-2 5×5 neighbour `< -0.1` at `:129-137`; no mask-B term. | [O] |
| E9 | `mapgen.gd:180-215` | Texture load at `:166,180`; block bounds `sx0/sx1, sy0/sy1` at `:187-191`; per-pixel accumulate at `:196-205`; white skip at `:199-201`; averages at `:208-210`; `hw` at `:212`; `height = hw + relief(cr)` at `:213`; `smooth` at `:214`; `forest = cg/255` at `:215`. | [O] |
| E10 | `mapgen.gd:216-238` | Water count `height < WATER_DEEP` at `:216-217`; `passes = 3/2/1` at `:220-224`; radius-1 diagonal average with lerp 0.5 at `:226-235`; returns fields at `:236-238`. | [O] |
| E11 | `data/scripts/common.inc/generatemap.inc:4-32` | Donor constants: heights 2.964 / 2.964/2.25 / −2.964 / −1.1; R codes 255/96/48 + smooth 191/112/88/64; G codes 255/64/128/192 (+127 = 255 div 2); B code 255. Every line is `[*] = ;` intent text. | [O] text / runtime [U] |
| E12 | `generatemap.inc:311-347,410-443` | Source-bitmap scan; start iff `fr=fg=fb=1`, then `fr=fg=fb=0`; **identical-coordinate dedupe only** at `:417-435`. | [O] text |
| E13 | `generatemap.inc:444-490` | `ir/ig/ib = floor(c*255)`; R class + bsmooth at `:454-472`; G 5-class enum at `:473-485`; water class iff `ib=255` at `:486-490`; `broad` from `fa` at `:450-453`. | [O] text |
| E14 | `generatemap.inc:537-547` | Target-bitmap resample: `bitmapx = floor((x/mapwidth)*trgwidth)`, same for y; **nearest pixel**, no averaging. | [O] text |
| E15 | `generatemap.inc:563-574` | `hwater = cWaterHeight*(fb*(1+fr*3.5))`; `hterrain` by class × `fr`; `//*(255/cRColor*)` suffixes disabled at `:571-572`; start skip requires `fr=1 and fb=1` at `:565-566`; `SetHeightData(realx,realy,hwater+hterrain)` at `:574`. | [O] text |
| E16 | `generatemap.inc:544-546` | Second-pass sampler assigns `.r` and `.b`; **`.g := fg` is commented out** at `:545`. | [O] text |
| E17 | `generatemap.inc:580-596,598-643` | `bsmooth` → `SmoothTerrain(realx,-realy,False,3)` at `:591`; whole-map `_misc_SmoothTerrainCustom(...,4,0.5,0.01,100)` at `:606`; 3 coastal passes gated by `gMapMask.water=cBWater` or radius-2 water neighbour (`:621-635`) and `power=0.35, lerp=0.5, h∈[−100,−0.01]` at `:637`. | [O] text; kernels [U] |
| E18 | `data/scripts/common.inc/texturemap.inc:29-31,464-470` | `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`; tile water/shore tag requires `gMapMask.b>0` **and** height band. | [O] text |
| E19 | `docs/.../reports/F04_masks.md:37-75,189-252,385-438,448-499` | Donor pixel truth: R/G zero off starts; B all 256 values; `h=-1.1*B/255`; water `B≥58`; 5,125 vanilla starts; 56 port PNGs pixel-identical; decoder recipe. | [O]/[D] (F04, re-verified P3) |
| E20 | P3 in-memory re-decode (this ticket) | `med/22`: shape 320², 4 starts, 22 px at B=58, `(B>58)=0.213643`, `(B>=58)=(h<-0.25)=0.213857`, `h(B=58)=-0.250196`, non-start R sum 0; `nowater2/176`, `islands/0`, `peninsulas/0` R/G non-start sums 0 and starts exactly as F04; med/22 PNG == donor TGA pixel-for-pixel. | [O] computed, no file written |
| E21 | `spec/README.md:19`; `spec/03_MASK_TO_HEIGHT.md:1-55`; `spec/05_WATER_SHORE.md:19-32`; `reports/A03_asset_pipeline.md:276,296` | README still marks §03 PENDING but the file landed mid-ticket with two stale claims (`:21-26`, `:32-33`); §05 states coastal gate is B+band and flags `mapgen.gd:179-196`; A03 requires `decode_donor_mask_new.py` and a validation check that currently mirrors the manifest. | [O] repo text |

## 2. Findings per file

### 2.1 `variant3d/tools/import_donor_masks.py` — line-by-line [O]

| Lines | Code / action | Consequence vs F04 truth | Label |
|---|---|---|---|
| `:1-16` | Docstring. `:5` channel table; `:7-9` "gauss variants only carry water (R/G zero except starts)", RGB copied so format stays identical; `:12` usage still says `app/tools/` (stale); `:15` private-use note. | The channel statement is **correct for shipped pixels** (F04 §5.1, E20); it is donor *intent*, not a decoded relief field. No height is computed here. | [O] port text; pixel claim [O] via F04 |
| `:29-36` | `$COSSACKS3_DIR` default; `donor_for()` → `data/gen/terrainmasks`; `OUT`/`MANIFEST` under `assets/terrain/masks`. | Hard-coded single root; no `.src` or `.dlc5` traversal. | [O] |
| `:37` | `PER_TYPE = 8` ("keep the asset set light"). | 8 per type × 7 types = 56 = 4.2 % of 1,331 vanilla masks; 0/1,856 DLC5 (F04 §9:433). | [O]/[D]; **PORT APPROXIMATION** |
| `:40-64` | `start_dots()`: `:45` white = R&G&B==255; `:46-49` scan; `:50-60` BFS over **4** neighbours (`:56`); `:62-63` centroid normalised by source `w,h`. | Donor detects **each white pixel** and dedupes only identical coordinates (`generatemap.inc:413-443`); a 4-connected component merges the six known 1–2 px near-duplicate starts (F04 §8). Centroid == exact pixel for singleton components (matches manifest ±1 px, F04 §9:431). | [O]; divergence = **PORT APPROXIMATION** (deliberate de-dupe guard, endorsed by F04 §11.4) |
| `:74-93` | Lazy numpy import; `OUT.mkdir`; loop folders (`:78-79`); glob `*pl*_gauss.tga` (`:81`); `step`/`chosen` (`:85-86`); `Image.open(...).convert("RGB")` (`:92`); `np.asarray` (`:93`). | Pillow honours 24-bit RLE and TGA descriptor bit 0x20; F04 §4/§9:430 and E20 confirm 56/56 byte-identical PNGs. **No TGA-header validation, no RLE packet validation, no orientation assertion in this tool** — correctness is inherited from Pillow. | [O] |
| `:94-97` | Save PNG under `<folder>/<stem>.png`, `optimize=True`. | Lossless RGB copy; start pixels are **not** zeroed in the PNG (donor zeroes them after recording — `generatemap.inc:440-443`). `mapgen.gd:199-201` compensates at runtime. | [O]; compensating skip = **PORT APPROXIMATION** |
| `:98` | `water = float((rgb[:,:,2] > 58).mean())`. | (i) `>58` = B≥59 but `h<-0.25` ⇔ B≥58 (`-1.1*58/255 = -0.250196`, E20) → off-by-one; (ii) includes white starts. Med/22: 0.213643 vs 0.213857 (E20). A03:296 validation mirrors this value. | **BUG-1/BUG-2** (diagnostic only; height path unaffected) |
| `:99-103` | Append `{file, starts, water: round(water,4)}`. | No relief field, no bsmooth flag, no water-*class* (B=255) field, no per-field provenance/label, no `visual_parity_claim:false` (A03:80,299). | **MISSING** |
| `:105-114` | `data` dict with `note` at `:108`; write manifest; print totals/size. | `note` repeats donor intent; no schema version beyond `version:1`; no `--dry-run`/`--check` (A03:98,276). | **MISSING** |

**No divergence found** in the actual TGA→RGB byte copy: descriptor handling, BGR→RGB and RLE are delegated to Pillow and independently confirmed by F04 §2,§4,§9 and E20. **[O]**

### 2.2 `variant3d/scripts/mapgen.gd` — line-by-line [O]

| Lines | Code / action | Consequence vs F04 truth | Label |
|---|---|---|---|
| `:1-9` | Header comments: "R = relief 255/96/48, G = forest/stone, B = water, pure white = start"; formula at `:5`; "This file does exactly that". | Correct as **donor intent** (`generatemap.inc:4-32`), but on shipped pixels R/G are start-only (F04 §5.1) — the comment overstates what this file can actually produce. | [O] port text; **PORT APPROXIMATION** if read as pixel truth |
| `:25-30` | Six donor constants. | All match F04 E6 / `generatemap.inc:4-7` and `texturemap.inc:30-31`. `WATER_SHORE` is declared but never used in this file. | [O] |
| `:32-61` | Manifest cache; `types()`; `mask_count()`; `pick()` with `r.seed = (seed ^ type.hash()) + 104729` and `r.randi() % size` (`:59-61`). | Deterministic *port* choice; no donor seed/RNG recovered (D02 scope). Changes which mask is consumed. | **PORT APPROXIMATION** / [U] donor RNG |
| `:63-85` | `relief(v)`: `roundi(v)` (`:76`), exact codes 255/191→`2.964*fr` (`:78-79`), 96/112→`(2.964/2.25)*fr` (`:80-81`), 48/88→`-2.964*fr` (`:82-83`), else 0 (`:84-85`). | Matches donor class×fr at `generatemap.inc:569-573` (disabled multipliers at `:571-572` are preserved as inactive in both F04 §10 and port) and F04 §10 step 3. **Inert on shipped data: R=0 off starts** → relief≡0. | [O] agreement; inert [O] |
| `:87-94` | `relief_smooth()`: true for codes 64/88/112/191 (`:94`); comment says no kernel invented (`:87-91`). | Matches donor `bsmooth` codes (`generatemap.inc:456,460,464,469`). On shipped data all false → donor `SmoothTerrain` pass (`generatemap.inc:580-596`) is inert. Port carries the flag as data only: correct decision, but downstream wiring is **MISSING**. | [O] / **MISSING** (kernel) |
| `:96-117` | `_starts_from_mask()`: normalise→pixels (`:99-101`); if ≥2 take farthest pair (`:102-115`); invented 0.125/0.875 fallback (`:116-117`). | Donor keeps **all** `Npl` starts in scan order (`generatemap.inc:415-435`; F04 §9:437). Port is right for 2-player maps, wrong for 3–8 players. | **PORT APPROXIMATION** (labelled in code `:103-104`) |
| `:119-143` | `_near_water()`: `height[i] < 0.8` (`:126`) else 5×5 radius-2 scan for `height < -0.1` (`:129-137`). | Mask-only height ∈ [−1.1, 0] → `:126` is **always true** → `near[i]=1` for every cell → no coastal restriction. Donor gate is `gMapMask.water=cBWater` (B byte =255) or radius-2 water-class neighbour (`generatemap.inc:621-635`), with band `[−100,−0.01]` at `:637`. Verified spec §05:27-28 already flags this port gate as wrong. | **BUG-3** |
| `:145-161` | `build()` signature; allocate height/forest/smooth; empty-manifest fallback (`:155-161`). | Allocates zeros — consistent with donor zeroing starts, but no sentinel distinguishing "no mask" from "flat mask". | [O] / [I] |
| `:162-179` | Texture2D load (`:166`) + recursive land fallback (`:169-179`, depth≤4). | Export-safe load is correct for PNG assets (F04 §9); recursion changes `seed+1` on fallback — port-only behaviour. | **PORT APPROXIMATION** |
| `:180-185` | `get_image()`, convert to RGB8, `iw,ih`, `water=0`. | No assertion that `iw==ih==320`, no check that R/G are start-only. | **MISSING** (QA guard; F04 §14 A05 asks for it) |
| `:186-210` | `sy0/sy1`, `sx0/sx1` from `int(f/y*size)` (`:187-191`); accumulate `c.r/c.g/c.b*255` (`:198-205`); skip pure-white (`:199-201`); divide by `n` (`:208-210`). | At 320²: `sx1=sx0+1`, `sy1=sy0+1` → exactly one source pixel → **identical** to donor nearest-pixel `generatemap.inc:541-543` (F04 §9:434). At 240² it averages 1–2 pixels → **PORT APPROXIMATION** (F04 §9:435). White skip mirrors donor zeroing but only for exact white; donor skip at `:565-566` tests `fr=1 and fb=1` (no G). | [O]; divergence at non-320 = **PORT APPROXIMATION** |
| `:211-215` | `hw = -1.1*(cb/255)*(1+(cr/255)*3.5)` (`:212`); `height = hw + relief(cr)` (`:213`); `smooth` (`:214`); `forest = cg/255` (`:215`). | Height formula is **exactly** `generatemap.inc:567` + class term for shipped R=0 → verified vector agreement (E20, F04 §9:434). `forest` is a continuous field, not the donor 5-class G enum (`generatemap.inc:473-485`); donor even comments out `.g` in the second pass (`:545`). On shipped data G=0 → forest≡0, so no wrong output today. | formula [O]; forest = **PORT APPROXIMATION** |
| `:216-217` | `if height[i] < WATER_DEEP: water += 1`. | Donor tile tag also requires `gMapMask.b>0` (`texturemap.inc:464-470`). For shipped data `h<-0.25 ⇒ B≥58 ⇒ b>0`, so equivalent; gate omitted. | **PORT APPROXIMATION** (inert) |
| `:218-235` | `passes=3/2/1` by quality (`:220-224`); `near` (`:225`); radius-**1** diagonal average, lerp 0.5, interior-only (`:226-235`). | Donor: 3 passes with radius-2 **water-class** gate and `power=0.35, lerp=0.5, band[−100,−0.01]` (`generatemap.inc:611-637`), plus whole-map pass `:606` and bsmooth pass `:591` — none of which the port implements. Kernel is native/UNVERIFIED (F04 §13.3, spec §05:19-28). | **PORT APPROXIMATION** + **BUG-3** gate + **MISSING** passes |
| `:236-238` | Return height/forest/starts/mask/water/relief_smooth. | Water returned is port's own count, not manifest `water` — so BUG-1/2 do not leak into height generation, only into the manifest/QA. | [O] |

## 3. Gap table — every divergence from F04 donor truth

Legend: **BUG** = would produce wrong height/forest/starts or a wrong diagnostic;
**PORT APPROX** = labelled substitute; **MISSING** = not implemented. Severity is
port-internal; no donor-parity verdict.

| # | Divergence | Port cite | Donor/F04 truth | Class | Impact on shipped data |
|---|---|---|---|---|---|
| G1 | `B > 58` ⇒ integer B≥59 | `import_donor_masks.py:98` | `h<-0.25` ⇔ B≥58 (`generatemap.inc:567`; F04 §6,§9:432) | **BUG** (low, manifest only) | Med/22 undercount 0.000214; 22 px at B=58 (E20) |
| G2 | White start pixels counted as water in manifest | `import_donor_masks.py:98` | Starts zeroed then skipped (`generatemap.inc:440-443,565-566`; F04 §10 step 1) | **BUG** (low, manifest only) | +4/102400 for `nowater2/176` (E20); rounds to 0 at 4 dp |
| G3 | Coastal gate `height<0.8` always true | `mapgen.gd:126` (used `:225-235`) | `water` class B=255 + radius-2 class neighbourhood + band `[−100,−0.01]` (`generatemap.inc:621-637`; spec §05:27-28) | **BUG** (high, height) | All interior cells smoothed; shoreline profile altered |
| G4 | `land` reads `terrainmasks/land` | `import_donor_masks.py:78` | Live Land path is `nowater2` (`generator.cfg:5`; F04 §9:438) | **BUG** (config-level) | "land" maps get up to 24 % water |
| G5 | 8 masks/type; no `.src`, no DLC5 | `import_donor_masks.py:37,78-86` | 118–320 final masks/type; 1,856 DLC5 (`F04 §3`) | **PORT APPROX** (explicit `:37`) | 56/1,331 vanilla, 0 DLC5 |
| G6 | 4-connected white components + centroid | `import_donor_masks.py:45-63` | Per-pixel white detection, identical-coord dedupe only (`generatemap.inc:413-443`; F04 §8) | **PORT APPROX** | Merges the six 1–2 px duplicate starts; harmless for singletons |
| G7 | All-but-2 starts discarded | `mapgen.gd:102-115` | All `Npl` starts kept (`generatemap.inc:415-435`; F04 §9:437) | **PORT APPROX** (code-labelled) | Wrong player count for 3–8 pl |
| G8 | Invented 0.125/0.875 fallback starts | `mapgen.gd:116-117` | No donor rule | **PORT APPROX** | Only on manifest-miss path |
| G9 | Block averaging at non-320² | `mapgen.gd:186-210` | Nearest-pixel target sample (`generatemap.inc:541-543`; F04 §9:435) | **PORT APPROX** | Exact at 320²; shore width differs at 240² |
| G10 | `forest = G/255` continuous | `mapgen.gd:215` | 5-class enum; `.g` commented out in 2nd pass (`generatemap.inc:473-485,545`; F04 §10 step 4) | **PORT APPROX** | Inert (G=0 off starts) |
| G11 | Water count omits `B>0` gate | `mapgen.gd:216-217` | `b>0 AND h<-0.25/-0.1` (`texturemap.inc:464-470`) | **PORT APPROX** | Inert (h<-0.25 ⇒ B≥58) |
| G12 | Radius-1 diagonal smoother, lerp 0.5, no band | `mapgen.gd:226-235` | radius-2 class gate, `power=0.35`, band `[−100,−0.01]` (`generatemap.inc:611-637`) | **PORT APPROX** | Height differs wherever G3 applies |
| G13 | Whole-map pass + bsmooth pass absent | `mapgen.gd:218-235` vs `generatemap.inc:591,606` | Both donor passes exist; kernels [U] | **MISSING** | No effect on vanilla final masks (bsmooth all false) but stage incomplete |
| G14 | No R relief field / bsmooth / water-class in manifest; no `.height.png` | `import_donor_masks.py:99-103`; `mapgen.gd:214` | A03:276,296 require `masks/height/**/*.height.png` + label | **MISSING** | Blocks fresh module contract |
| G15 | No header/RLE/orientation assertion; no start-count guard | `import_donor_masks.py:92-97`; `mapgen.gd:180-185` | F04 §4,§14 (A05 guard) | **MISSING** | Anomaly masks (F04 §8,§5.3) unguarded |
| G16 | No `--dry-run` / `--check` / per-field provenance / parity flag | `import_donor_masks.py:67-114` | A03:80,98,276,299 | **MISSING** | Cannot satisfy A03 validation closure |
| G17 | Port RNG chooses mask | `mapgen.gd:58-61` | No donor seed/RNG recovered | **PORT APPROX** / [U] | Different mask for same seed than donor |
| G18 | `note` describes R/G as relief/forest | `import_donor_masks.py:108` | Shipped R/G are 0 off starts (F04 §5.1, E20) | **PORT APPROX** (intent-level text) | Misleading to consumers, not a runtime fault |

**No divergence**: TGA byte copy (E5/E20/F04 §9), height formula `:212-213` at 320²,
relief code table `:75-85`, bsmooth code table `:92-94`, orientation, and the
decision not to invent a native smoothing kernel. **[O]**

## 4. Multiple-pass resolution of contradictions

Per CHARTER.md:85-93, each contradiction was re-run with a second/third instrument
before a reading was accepted.

**C-A — "gauss R/G zero except starts" vs "R is genuine height data"** (P04 U-6,
`P04_tool_audit.md:112,166`; `H03_heightmap_hypothesis.md:63,129`).
- Pass 1 (text): H03-E12 quotes `import_donor_masks.py:4-9,108` **including** "gauss
  masks carry water only (R/G zero except starts)"; H03:129 calls R "genuine height
  data" while its C3 verdict (`:125-143`) is about R not being *drawn as albedo*.
- Pass 2 (pixels): F04 §5.1 — R/G have exactly two values, 0 (136,289,275 px) and
  255 (5,125 start px) across 1,331 masks.
- Pass 3 (fresh decode, E20): non-start R sum = 0 and G sum = 0 in med/22,
  nowater2/176, islands/0, peninsulas/0.
- **Accepted**: both statements are true in different frames — donor *intent*
  (`generatemap.inc:4-32,454-485`) defines R relief / G forest codes, but **shipped
  pixels never exercise them**. P04's U-6 is **RESOLVED** by F04; the port's R/G
  handling is inert, not wrong. No parity claim.

**C-B — `B>58` vs `h<-0.25`** (`import_donor_masks.py:98`; F04 §6 "B ≥ 58.1").
- Pass 1 (algebra): `-1.1*B/255 < -0.25` ⇔ `B > 57.9545` ⇒ integer **B≥58**;
  port's `>58` ⇒ B≥59.
- Pass 2 (F04 numbers): med/22 correct water 0.2139 vs manifest 0.2136 (F04 §9:432,
  §7.2:308).
- Pass 3 (fresh decode, E20): 22 pixels at B=58; `(B>58)=0.213643`,
  `(B>=58)=(h<-0.25)=0.213857`; `h(58)=-0.250196`.
- **Accepted**: genuine one-value off-by-one in the manifest diagnostic only; keep
  G1 as BUG with low severity. F04's fractional "B≥58.1" must be read as integer
  B≥58 (and shore "B≥23.2" as integer **B≥24**).

**C-C — port `mapgen.gd:179-196` cited by spec §05:28 vs current line numbers**.
- Pass 1: spec §05:28 says the port's coastal logic is at `:179-196`; current file
  has texture loads at `:166-185` and smoothing at `:218-235`.
- Pass 2: F04 §9:436 independently cites `:218-235`; F04 §9:434-435 cites `:212-215`
  and `:186-205` — all match the current file.
- **Accepted**: spec §05's citation is **stale line drift**, not a different code
  version; re-cite `:119-143` (gate) and `:218-235` (passes). The substantive claim
  (port gate is height-only, donor gate is B+band) stands and is corroborated by
  `generatemap.inc:621-637`.

**C-D — 4-connectivity (port) vs 8-connectivity (F04 §2) vs per-pixel (donor)**.
- Pass 1: `import_donor_masks.py:56` uses 4 neighbours; F04 §2 item 4 used
  8-connected components for its statistics.
- Pass 2: `generatemap.inc:413-443` records each white pixel and dedupes only
  identical coordinates — neither connectivity applies to the donor.
- Pass 3: the six known duplicate masks have separations 1–2 px (F04 §8); both
  connectivities merge them, and F04 §11.4 explicitly recommends a merge guard.
- **Accepted**: port behaviour is a **PORT APPROXIMATION** that happens to match
  F04's recommended guard; it diverges from donor start *count* on six vanilla
  masks and both DLC5 grey-pixel masks. No parity claim.

**C-E — is the port's `forest=G/255` a BUG?**
- Pass 1: `mapgen.gd:215` is a continuous field; donor has a 5-class enum
  (`generatemap.inc:473-485`) → structurally wrong.
- Pass 2: F04 §10:499 explicitly labels this divergence **PORT APPROXIMATION**.
- Pass 3 (pixels): G=0 on all non-start pixels (F04 §5.1, E20); donor even comments
  out `.g := fg` in the second pass (`generatemap.inc:545`).
- **Accepted**: **PORT APPROXIMATION**, inert on shipped data. Do **not** upgrade to
  BUG without a mask that actually carries G codes.

**C-F — spec §03:32-33: "the port's `mapgen.gd:51-61` uses a wrong-sign `relief()`
(code bug for I07 to fix)"** (`A02_algorithm.md:116,160,298`).
- Pass 1 (current code): `mapgen.gd:63-85` is headed `RCODE-FIX-01`; `:82-83` returns
  `C_RAVINE*(88/255) = -2.964*88/255 = -1.0226` for R=88 (negative, correct), and
  `:84-85` returns 0 for R=64 (no spurious bump). There is no `relief()` at
  `:51-61` in the current file (`:51-61` is `pick()`).
- Pass 2 (donor text): `generatemap.inc:463-465` maps ir=88 to `cRRavine` with
  `bsmooth=true`; `:569-573` sets `hterrain = cRavineHeight*fr = -2.964*fr`; the
  `else` at `:467-471` gives `cRNone`/no hterrain, i.e. 0 for ir=64.
- Pass 3 (line-drift check): A02 and spec §03 both cite `mapgen.gd:51-61`, which in
  this checkout is `pick()`; F04 §9 cites the live `:212-215` correctly. The stale
  range plus the `RCODE-FIX-01` marker show those reports describe a **pre-fix**
  file.
- **Accepted**: the "wrong-sign `relief()`" claim is **STALE for the current file**;
  I07 must **not** flip a sign or add a class bump — doing so would introduce the
  bug the report warns about. Note also spec §03:31's `{2.964/1.31733…/−2.964}*fR`
  treats 1.31733 (= 2.964/2.25) as a divisor; it is the *disabled-multiplier*
  hill amplitude (`generatemap.inc:571-572`), and both F04 §10 step 6 and the port
  use `class × fr` with those suffixes inactive. No per-code amplitude rewrite is
  justified. Genuine I07 work is G1/G3/G4/G6/G7/G13-G16. **[O]/[D]**; no parity claim.

**C-G — spec §03:21-26 "F04 vs A02 contradiction, R/G class semantics `[U]`"**.
- Pass 1: spec §03:21-26 frames F04's measured vanilla `_gauss` pixels against
  A02 E06/E08's `generatemap.inc` source-bitmap semantics.
- Pass 2: `generatemap.inc:342-370,454-485` defines the R class / G forest codes,
  but `generatemap.inc:544-546` assigns only `.r` and `.b` in the second pass (`.g`
  commented out at `:545`).
- Pass 3: F04 §5.1 and E20 re-measure R=G=0 on all non-start pixels.
- **Accepted**: no contradiction — **intent vs shipped pixels** (same resolution as
  C-A). Keep `h=-1.1*B/255` as the observed vanilla fact; keep the class decode as
  donor-intent code that is inert on all shipped final masks. Do not mark the
  observed fact `[U]`. **[O]/[D]**

## 5. Implementation-ready decoder recipe (for I04/I07 / `decode_donor_mask_new.py`)

All steps are `[O]` from cited text/pixels unless marked. Keep every derived field
labelled; no donor parity claim.

### 5.1 Exact formula

```
# decoded, visually top-down pixel (R,G,B) as bytes 0..255; fr=R/255, fg=G/255, fb=B/255
if R==255 and G==255 and B==255:          # generatemap.inc:413-443,565-566
    record start (x,y); set (fr,fg,fb)=(0,0,0)   # donor zeroes after recording

ir = floor(fr*255); ig = floor(fg*255); ib = floor(fb*255)   # :444-446

class = {255,191:'plateau', 96,112:'hill', 48,88:'ravine'}.get(ir,'none')  # :454-472
bsmooth = ir in {191,112,88,64}                              # :456,460,464,469
forest_enum = {255:'forest',127:'forest(if class!=none)',64:'gen_forest',
               128:'stone',192:'forest+stone'}.get(ig,'none')# :473-485
water_class = (ib == 255)                                    # :486-490  <-- exact byte

hwater   = -1.1 * fb * (1 + 3.5*fr)                          # :567
hterrain =  2.964*fr            if class=='plateau'          # :570
         = (2.964/2.25)*fr      if class=='hill'             # :571 (multiplier //-disabled)
         = -2.964*fr            if class=='ravine'           # :572 (multiplier //-disabled)
         = 0                    otherwise
h = hwater + hterrain                                        # :574

# SHIPPED DATA (fr=0 on all non-start px, F04 §5.1):  h = -1.1*B/255  ∈ [-1.1, 0]
tile_water_tag = (B > 0) and (h < -0.25)                     # texturemap.inc:464-467
tile_shore_tag = (B > 0) and (h < -0.10)                     # texturemap.inc:469-470
coastal_eligible = water_class or any water_class in 5x5 (radius 2)  # :621-635
```

**Integer thresholds [D]** (with fr=0): water `B≥58`; shore `B≥24`; water *class*
`B==255`; deep bed `B=255 → h=-1.1`. Do **not** use `B>58` and do **not** use a
binary `B==255` water test for tile selection (F04 §11.3).

### 5.2 Converter (`decode_donor_mask_new.py`, new file — not an edit to the legacy tool)

1. **[O]** Read 18-byte TGA header; assert `idlen=0`, `cmtype=0`, `itype=10`,
   `depth=24`, dimensions 320×320 (final `_gauss`) or 256×256 (`.src`), alpha bits
   0; honour descriptor bit `0x20` (final `0x00` bottom-left → flip; masters `0x20`
   top-left) — F04 E3-E5, §4. Decode RLE packets (`bit7`, `count=(b&0x7f)+1`), BGR→RGB.
   Cross-check against Pillow byte-for-byte (F04 §2).
2. **[O]** Detect starts per pixel as exact `(255,255,255)`; record exact integer
   coords in scan order; dedupe only identical coords; zero those pixels in the
   copied field; keep all `Npl` starts (A03/A01 decision) — `generatemap.inc:413-443`.
   If merging 1–2 px duplicates, label it **PORT APPROXIMATION** (F04 §8).
3. **[O]** Emit the **raw R channel** as `masks/height/**/*.height.png` plus a mask
   index carrying `starts`, `water_fraction` computed from `h<-0.25` **excluding
   starts**, `water_class_fraction` (B==255), `bsmooth_fraction`, `source_sha256`
   and per-field labels (A03:276,296; F04 §10). Keep PNG pixels byte-identical to
   the decoded TGA (F04 §9:430) — that is the orientation/byte guard.
4. **[O]** Cover every mask in each shape folder and add `.dlc5` shapes
   (coastal/lakes/rivers); optionally keep `.src` masters as a separate, labelled
   corpus (F04 §3). Remove `PER_TYPE` from the fresh tool; keep it only in the
   frozen legacy tool (A03:280).
5. **[U]** Do **not** invent smoothing kernels, RNG, px→cm scale, `fa`/`broad`, or
   forest density. Emit `null` + `UNVERIFIED` for those slots (A03:291,299).

### 5.3 Validation vectors (real donor files, re-decoded P3)

| Vector | Donor path (SHA prefix from F04) | Expected decode | Use |
|---|---|---|---|
| V1 | `data/gen/terrainmasks/nowater2/4pl_mask_nowater_176_gauss.tga` (`05fefad3…`, 3,908 B) | Header `00 00 0A 00 00 00 00 00 00 00 00 00 40 01 40 01 18 00`, 320², desc `0x00`; starts `(41,41),(278,41),(63,256),(256,256)`; 102,396 non-start px R=G=B=0 → h≡0, forest=none, water=0 (excluding starts) | Flat-map zero-height test; detects orientation flip and false relief [O] |
| V2 | `data/gen/terrainmasks/mediterranean/4pl_mask_mediterranean_22_gauss.tga` (`159eb0a7…`, 27,969 B) | Starts `(39,31),(192,164),(62,262),(289,288)`; 22 px at B=58; `(h<-0.25)=0.213857`, `(B>58)=0.213643`; y=120 transect `(35,0,0.0000),(36,1,-0.0043),(37,7,-0.0302),(38,31,-0.1337),(39,97,-0.4184),(40,194,-0.8369),(41,246,-1.0612),(42,254,-1.0957),(43,255,-1.1000)`; port PNG 100 % identical (E20) | **BUG-1 regression test** (exact 0.000214 delta); continuous-ramp test [O] |
| V3 | `data/gen/terrainmasks/islands/2pl_mask_islands_0_gauss.tga` (`540ef4fb…`, 65,987 B) | Starts `(99,68),(189,260)`; B mean 157.3472; h mean ≈−0.6787 (starts excluded); water ≈0.6422; R/G non-start sums 0 | High-water / farthest-pair test [O] |
| V4 | `data/gen/terrainmasks/peninsulas/2pl_mask_peninsulas_0_gauss.tga` (`b342397d…`) | Starts `(149,81),(268,275)`; B mean 122.905; h mean −0.5302; water 0.492637 | Mid-water shape test [O] |
| V5 | `data/gen/terrainmasks.src/mediterranean/4pl_mask_mediterranean_22.tga` (`7ac2e9c8…`) | 256², descriptor `0x20` (top-left), B strictly {0,255}, R/G start-only | Orientation / master-vs-gauss test [O] |
| V6 | `land/4pl_mask_land_113_gauss.tga`, `land/4pl_mask_land_114_gauss.tga`, `mediterranean/4pl_mask_mediterranean_{51,62}_gauss.tga`, `islands/2pl_mask_islands_98_gauss.tga`, `peninsulas/4pl_mask_peninsulas_5_gauss.tga` | Filename `Npl` undercounts white pixels by 1 (near-duplicate 1–2 px) | Starts-count guard; do not assert `Npl == marker count` [O] (F04 §8) |
| V7 | `data/gen/terrainmasks.dlc5/continents/8pl_mask_continents_{8,9}_gauss.tga` | 7 starts though named 8pl; grey pixels R=G=B at (68,38)=7,(69,38)=5,(67,39)=145,(68,39)=128 (and mirrored coords in _9) | Do not assume RGB ∈ {0,255}; do not derive relief from grey pixels [O] (F04 §5.3) |

**Gate assertions** (implementation-ready): decoded pixel bytes == committed SHA;
`iw==ih==320`; non-start R/G sums == 0 for vanilla final masks; `starts` == exact
white pixel list; `water_fraction` computed with `B≥58` **excluding starts**;
`water_class_fraction` computed with `B==255`; zero relief amplitude >0 from masks
alone; no parity flag set to true (A03:299; F04 §14 A05 request). **[D]/[O]**

## 6. Implications for spec §03 (`03_MASK_TO_HEIGHT.md`, pending)

1. **[O]** §03 is now on disk as `spec/03_MASK_TO_HEIGHT.md:1-55` (COORD landed it
   while this ticket ran; `spec/README.md:19` still says PENDING — stale). It
   correctly states F04's shipped-pixel truth (`:9-19`) but its `:21-26`
   "F04 vs A02 contradiction / `[U]`" and its `:32-33` "wrong-sign `relief()` — I07
   bug" are resolved by C-G and C-F above: both are stale/intent-vs-pixel
   confusions. §03 must **not** adopt `import_donor_masks.py:5,108` or A03:92 as
   *pixel* truth, and must not send I07 to flip a correct sign.
2. **[O]** §03 must separate the three water notions (§0.5 above) with their own
   thresholds: class `B==255`, bed `h=-1.1*B/255`, tile tag `B>0 ∧ h<-0.25/-0.1`.
   Conflating them is the root of G1/G2/G3/G11.
3. **[O]** §03 should carry the validation vectors V1–V7 as normative assertions,
   including the **exact** water delta at B=58, so the A03:296 check is corrected
   rather than inheriting the off-by-one.
4. **[O]** §03 must mark `SmoothTerrain` / `_misc_SmoothTerrainCustom` kernels and
   the stage order relative to pattern stamps **UNVERIFIED** (F04 §13.3,§13.7;
   D03/D05 scope) and explicitly forbid inventing a kernel. Port's `relief_smooth`
   flag is inert on shipped final masks — record that as an observed fact.
5. **[O]** §05's stale citation `mapgen.gd:179-196` (`spec/05_WATER_SHORE.md:28`)
   should be re-pointed to `:119-143`/`:218-235`; its substantive claim is confirmed
   by `generatemap.inc:621-637` (C-C).
6. **[O]** §11 should note that A03's `decode_donor_mask_new.py` is **not yet
   implemented** and that G14–G16 are blockers for consuming its output in the
   fresh module. A06's pointer switch must not point at the legacy mask path.

## 7. Risks

| # | Risk | Evidence | Mitigation |
|---|---|---|---|
| R1 | `B>58` off-by-one propagates into A03:296 validation | `import_donor_masks.py:98`; E20 | Use V2 vector; assert `B>=58` excluding starts |
| R2 | Global smoothing (G3) changes shoreline heights silently | `mapgen.gd:126`; `generatemap.inc:621-637` | Implement class-based gate; A/B against V2 transect |
| R3 | Fresh module reads legacy manifest and inherits G1/G2/G5/G7 | `mapgen.gd:36,96-117`; A03:280 | Distinct `terrain_new` schema (A03:43,307) |
| R4 | R relief codes "discovered" from the DLC5 grey pixels | F04 §5.3; V7 | Reject non-{0,255} R/G as data defects, not relief |
| R5 | Forest/mines expected from G | `mapgen.gd:215`; `generatemap.inc:545`; F04 §11.2 | Ingest patterns (D07/F08); leave G enum decode labelled |
| R6 | Wrong `land` shape (G4) survives into spec | `import_donor_masks.py:78`; F04 §9:438 | COORD/F03 decision; record chosen folder in manifest |
| R7 | Text-vs-runtime: all `.inc` rules are `[*] = ;` | `generatemap.inc:4-32,567` | Keep runtime activation [U]; no parity claim |
| R8 | Unit/scale: px→cm/m never recovered | F04 §13.2,§8 | Report pixels/fractions only |
| R9 | Line drift in cited reports (spec §05:28) | C-C | Re-cite current file:line in §03/§05 |
| R10 | No donor GPU A/B frame | CHARTER.md:41,125 | Honest parity verdict stays UNVERIFIED |

## 8. UNVERIFIED register — do not promote

1. **[U]** Runtime execution of `generatemap.inc` / `texturemap.inc` `[*] = ;` text in the shipped build (no donor binary executed).
2. **[U]** Native kernels of `SmoothTerrain` and `_misc_SmoothTerrainCustom` — port's smoother is **PORT APPROXIMATION** (F04 §13.3).
3. **[U]** How forest/stone **density** is derived if G is zero in vanilla masks: G enum is intent only and the second pass drops G (`generatemap.inc:473-485,545`); placement is pattern-stage (D07/F08). No density-from-G rule is asserted.
4. **[U]** `fa` value / `broad` road flag for a 24-bit TGA (`generatemap.inc:450-453`; F04 §13.2).
5. **[U]** Pixel→world cm/m scale for the start-spacing rule (F04 §8).
6. **[U]** Donor seed/RNG and mask choice (`mapgen.gd:58-61`; D02).
7. **[U]** Whether `.src` masks or `_gauss` are selected by config for a given map size (`F03`; F04 §14).
8. **[U]** Purpose of the 31 differing DLC5 masks and the four `.removed` files (F04 §13.5-6).
9. **[U]** Stage order: mask bed → pattern stamps → smoothing (`F04 §13.7`; D03/D05).
10. **[U]** Whether the port's global near[] smoothing was an intentional substitute or an oversight (code alone cannot decide).
11. **[U]** Any donor GPU A/B frame — none exists; no parity claim.

## 9. Open questions

- **D03:** Can the native coastal kernel and its exact band/lerp be recovered, so G12 can be replaced rather than merely re-labelled?
- **F03:** Which cfg key selects `_gauss` vs `.src`, and does the live Land path definitively stay `nowater2` (G4)?
- **COORD/A01:** Keep all `Npl` starts (donor-faithful) or the farthest pair (G7)? Decide before §03 freezes the start rule.
- **COORD/F03:** Does any live gate still consume the legacy `manifest.water` (G1/G2)? If yes, `validate_terrain_new.py` must use the corrected formula.
- **A05:** Add V1–V7 as hard assertions; in particular the B=58 exact delta and a check that non-start R/G sums are zero.
- **D07/F08:** Where does forest/stone density actually come from, given G=0 in shipped masks (UNVERIFIED #3)?
- **A06:** Confirm the fresh module never falls back to `terrainmasks/land` or the legacy manifest.

## 10. Five-line summary

- **[O]** The port has two disjoint mask decoders: `import_donor_masks.py` copies pixels + manifest (`:92-103`), `mapgen.gd` samples them into height/forest/starts (`:180-238`); no `decode_donor_mask_new.py` exists (A03:276).
- **[O]** At 320² the height formula `mapgen.gd:212-213` matches F04's `h=-1.1*B/255` exactly; R/G are zero off starts in all re-decoded donor masks — formula agreement, **no parity claim**.
- **[O]/BUG** `import_donor_masks.py:98` uses `B>58` (integer ≥59) instead of `B≥58` and counts white starts as water: med/22 0.213643 vs 0.213857 (22 px at B=58); `mapgen.gd:126`'s `height<0.8` gate is always true → global, not coastal, smoothing.
- **[O]/PORT APPROXIMATION** 8/type masks (no DLC5), 4-connected component starts, farthest-pair start reduction, 240² block averaging, `forest=G/255`, and the radius-1 smoother are labelled substitutes; the `land` folder choice is a config-level BUG (G4).
- **[U]** Forest/stone density from G, native smoothing kernels, stage order, RNG and any donor GPU A/B frame stay UNVERIFIED; §03 must use V1–V7 and the three distinct water thresholds B==255 / h=-1.1*B/255 / B>0∧h<-0.25.

*End of X19. Exactly one report written. No code, asset, config, test, git or Godot change; no donor binary executed or copied; no donor visual-parity claim.*
