# 06 — Tile ids and atlas (from F05; D08/F03/F06 pending)

Source: `reports/F05_tile_mapping.md` (482 lines, full id 0–123 table).
**PORT APPROXIMATION where noted; no donor parity claim.** F05 read donor text and
the port's atlas/assets read-only; no binary was run.

## 1. Donor tile space [O]

- **124 tile ids per season** — `terrain/tiles/terrain.presets:6–129` (Summer),
  `:138–261` (Winter); one-for-one `_winter` rename at the same preset index.
- Resolved through **245 `tiles.lib` geometry sections** and **253 `tiles.mat`
  material sections** to **108 distinct DDS paths**; 112 DXT1 files ship, of
  which `winter18/23/24/26.dds` are unreferenced.
- Port `variant3d/assets/terrain/blocks/**` has exactly **112 PNGs** with stems
  identical to the 112 donor DDS (E: direct count).

## 2. Atlas mapping [O]/[D]

- Port's 124-cell 16×8 atlas: cell `i → (i%16, i//16)`, index dictionary from
  `presets_summer.json`; **no index remapping**.
- **36 face cells are identity reuse** — no 25° tilt / `alphavert` treatment;
  **3 alpha sentinels are EMPTY holes** — both are **PORT APPROXIMATION** (F05 §).
- Exact alias classes recovered: rock `vf/vs` and sand `f/s` faces (25° overrides),
  `alpha0a/b/c → grass1.dds + alphanull`, desert winter reuse, byte-identical art
  groups (`grass1=test10=test11`, `grass8=test0`).

## 3. Id families (F05 §4) [O]/[U]

| Family | Tile ids |
|---|---|
| Cliff / rock | 17–25, 53–70 |
| Sand / shore | 26–52, 93–98 |
| Water | **no tile id** — port sentinel `255` is PORT APPROX |
| Mill fields | **decals**, not terrain tile ids |

`data/terrain/cliffs/**` and `covers/**` are 0-byte stubs; the
`texturemap.inc` selection rules are fully `;`-commented (intent only) — **[U]**
for engine behaviour. D08/F03/F06 must resolve the live selection rules.

## 4. Binding to the new module [D]

- Keep `UV2.x = tex[i]` (integer id) and `UV2.y = face ∈ {0,1,2}`; the atlas
  index dictionary is donor-faithful (F05 E). Fixing the 36 identity face cells
  and 3 empty alpha holes is a distinct, labelled improvement — not a silent
  change to the id space.
- Mill fields must come from the decal/prop path (`spec/08_FIELDS_AND_PROPS.md`),
  never by inventing a water/field tile id.
- Winter = index-preserving rename; desert winter reuse awaits F10 confirmation.

## 5. Cross-check queue

D08 (live selection + smoothing rules), F03 (`tilesmooth.cfg` grammar/rules),
F06 (`alpha.bmp`/`alphavert` exact math and sentinel mapping).

## 5. Alpha masks — donor truth vs port approximation (from F06) [O]

- Donor fragment shader does **no mask math**: RGB from `texUnit0`, mask
  intensity → `color.a` from `texUnit1` (`hf.pvl.smx3.frag:13-17,50`). Blend is
  **fixed-function `bmTransparency`** (enum index 1, `cossacks.exe:949234`);
  factors and pass count remain **[U]**.
- `alpha.bmp`: 512×256, 8 bpp, data@1070 = **8×4 patches of 64²**. Four constants
  255 at `(0,0)/(4,0)`, 0 at `(3,3)/(7,3)` (F06 § per-patch stats).
- `alphavert.bmp`: 1024×512, 24 bpp near-grey (94.3% R=G) — eye-linear cliff
  projection, `TextureScale=0.125` (`reftile.mat:120-169`).
- `alphanull` binds tile ids **86/110/123**; the port's "8 zero ids" are
  **PORT APPROXIMATION**, not donor truth.
- Port's id→patch bit decomposition, RGB multiply at shader `:427`, `ALPHA=1.0`
  and 0.35/0.5/step guards are all labelled PORT APPROX (F06 §).
- F05's 3 EMPTY alpha sentinel holes (§2 above) are therefore **not** a donor
  fact; they are a port placeholder awaiting the `alphanull` mapping.

## 6. Cross-check queue (updated)

D08 (live selection + smoothing), F03 (`tilesmooth.cfg` grammar/rules), F06 ✓
(alpha semantics above), D04 (tile ids in `.map`).

## 7. Visual validation (from X06) [O]

- F05 mapping confirmed: **124 ids = 85 DIRECT / 36 FACE_BASE_REUSE / 3 EMPTY**;
  all five family ranges zero-mismatch; **121/121 atlas cells pixel-exact** to
  declared PNGs. Labelled 16×8 sheet:
  `%TEMP%\opencode\atlas_audit\contact_sheet_124.png`.
- Byte identity verified 3 ways: `grass1=test10=test11` (ids 0/81/82),
  `grass8=test0` (7/71), `test19=winter23–26` (103 + 4 unmapped);
  112 files → 105 distinct hashes.
- Winter rename **124/124** one-for-one; 3 sentinel source exceptions and a
  52-entry `kind` label collision (shared art mislabelled as FACE_BASE_REUSE) —
  pixels/index intact.
- Diagonal lattice is real and broader than ids 14–16: rock ids 17–19/22–23
  (+ faces 53–70) FFT anisotropy **24.7–30.6**; `grass_ground1/3` 6.28/6.08 with
  mirrored peaks 145°/35°, id 16 an exact horizontal mirror of 14; **27/112**
  blocks ≥5 anisotropy. Atypical-but-correct names: 24/25 rock mossy, 26/27 sand
  greenish/blocky, 10 ground1 off-palette — visual cues for the owner's complaint.

## 8. Cross-check (updated)

D08 ✓, X08 ✓, X17, V20, I05 (atlas builder), I10 (shader).

---
*Integrated by COORD from F05 + F06 + X06.*


