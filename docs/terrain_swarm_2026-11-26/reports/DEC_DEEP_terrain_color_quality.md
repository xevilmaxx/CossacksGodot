# DEC-DEEP — Donor terrain color/quality path (TextureMap → Smooth → detail)

Target pinned: `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`, sha256 `87f0f3c1…`). Donor READ-ONLY. No code/Godot/git changes.
Context: candidate terrain looks flat/olive vs donor lush mottled ground in `cZW0AEupCaI`. Known port gaps: single tile id vs 4-corner tags, packed 128 px atlas vs 1024 px donor blocks, id-hash alpha vs LUT, Blinn-Phong without sceneColor, detail bitmap off, 88% test8.
Method compliance: max 5 passes per function. `FUN_00812e34`: 2 passes (study-summary + Ghidra pseudocode). Each helper (`00812b4c`, `00812ccc`, `0082e2f4`, `0050db08`, `0050daec`): 1 pass (pseudocode only). `0x8326b8`/`0x830754`: 1 pass each (find only). No parity claim.

## 1. Stage order [O]

- Donor script order is TextureMap (assign scalar tile ids) → SmoothTiles (3 passes, horizontal then vertical, in-place, full tile-map) → detail-bitmap pass (commented donor text, applied last, conditional). [O]
- Evidence (prior, reused): `fnd_23` (`ev_58552bae6226d2c3de4e5eee84758b5260199f1aab3f1514d442baef6`, `ev_de3fdab7fe79bd5d2e46012bc8d88e00b56cd684b9991d459a848261a`) — 3 passes H-then-V, file-order rule search, distance-1 no-op / distance-2 midpoint / larger step-one-list, `FindRandomTileIndex = RandomExt*sumProb` in-order cumulative test. `fnd_24` (`ev_e6f506430c087eef585bf67b46033ec20d0780933d04e6719f0722fb242b83d`) — detail is `320x320` 24 bpp low/high BMPs, `h<0.1` selects low, `tex=floor(r*255) div 2`, applied only where tile id is 0 and resolved name non-empty. `fnd_11` (`ev_bcc394eef001bba393521e2601feb0db8bc9cab3fc27553c0f7e3820e59`, `ev_d1d7ea4878eaa5801629fe4bab60134f93d804d7d8be28d9eb8776`) — `globalparams.cfg TileSmoothPasses=6` vs active `SmoothTileMap(...,3)`; 6-pass config not consumed by readable script.
- Why it matters for color: smoothing must run before detail/alpha so corner tags and masks are final; running detail before smooth or skipping smooth freezes olive single-id fill with no mottled transitions.

## 2. Tile id → art selection [O/D]

- Scalar tile ids are indices into season `terrain.presets` Blocks list (124 Summer + 124 Winter); each name resolves via `tiles.mat Material.Texture.image` to its block bitmap, `tiles.lib` for geometry overrides. 16×8 atlas packing in `variant3d` is port approximation, not donor image. [O/D] — `fnd_22` (`ev_e742a78dec8f3de16a07a5c1e6a83f3db7183b5b6a7a9b74b783e51852eb`, `ev_d77d8ef5230af3c11b7efc5ab1d7e4ea7da9f78f6dc21b7d68b46ac7d7ece`).
- Native art fetch is `FUN_0082e2f4` at `0x82e2f4` (Ghidra-made function, 1 pass): `FUN_0082e3dc(param_1)` count → `FUN_0082e064(tag,0,count-1)` membership test; if absent return `*(param_1+0x18)` default; else `FUN_0089df30(*(param_1+0x10),tag)` and fall back to default if 0. [D] — `ev_3498f84b3633e914cc87f5f18981bf92c7a7ef32eaca8d5b29460bc36f8672e5`.
- Port fix: replace single-id→atlas-cell with id→presets-index→`tiles.mat` image→block; keep `tiles.lib` override path; do not reuse packed-atlas UV stride.

## 3. `tsDouble` 8×8 subcell matrix [O/D]

- Shipped `tsDouble`/`ttExtended` terrain uses authored 8×8 RGB subcell matrix indexed by world-cell coordinates, 16 m macro period at 2 m per cell. Repeating one full tile every 2 m cannot reproduce donor ground and explains regular grass lattice. [D] — `fnd_48` (`ev_1d5e6e860588fbda27d4e2ddf2bdbcb81c186e9671e05860b9bfdd4110eeb367d`, `ev_b2e664174e1799a7e990a3c22fc872bdac88c7f39a259d05368bbf0859075438`, `ev_58d7418c2dc5d46b793f64c408ea8a2e343966838d0c28c26be68ff820221`).
- Renderer confirms 8-wide arithmetic: `FUN_00812e34` divides/mods by `*(byte*)(art+0x25)` then multiplies by `*(art+0x28)` for `iStack_28/iStack_2c`; `tsDouble` branch uses `*(art+0x24)` count with same `+0x28` block stride and second descriptor `+0x2d/+0x30` with `+0x2c` count. [D] — `ev_ceb19ad83d1757d17a40c3bf90f356b087c69d4795c476afc868385529b0a657` (`FUN_00812e34` at `0x812e34`, 87 blocks / 516 insn / 29 callees per `ev_0c031cb837c77c6d99028ae0752431772d548777d535f4b855fd3f8a5c60cdbb`).
- Port fix: implement `(x%8, y%8)` subcell index into 8×8 matrix with block stride `+0x28`; verify `+0x25==8` from art descriptor at runtime; do not stretch one tile over 2 m.

## 4. Smoothing weights [O]

- Same `fnd_23` rule as §1: file-order minimum `|list_index1-list_index2|`, distance-1 any-prob no-op, distance-2 weighted pick from midpoint list, larger gaps step one list toward target, `RandomExt*sumProb` selection. No per-weight float table in recovered text beyond `Prob` fields (e.g. sandsea5 `Prob=0.7`, sandsea6 `Prob=0.3` in shore lists per `fnd_9`). [O]
- Port fix: preserve file order + distance rule + cumulative-prob pick exactly; do not substitute uniform/hash pick (shifts hue toward olive mean).

## 5. Corner tags → sorted distinct → 4-bit mask → alpha LUT/insets [D]

- Donor alpha UVs come from four per-cell corner tile tags: distinct tags sorted, 4-bit occupancy mask formed, 16-entry parity LUT selects alpha patch. Port tile-id bit decomposition is not donor rule and caused black ground when detail ids enabled. [D] — `fnd_47` (`ev_58d7418c2dc5d46b793f64c408ea8a2e343966838d0c28c26be68ff820221`, `ev_e9694d0da085e0a3c3dcb0fb2d19548bbbdcffc6c3ac5fbbfad22c7e153b05db`, `ev_224b851c846058c075204f4c3df2ae2aa3639e6628b68e5a6dc4d9202a`).
- `FUN_00812e34` (`0x812e34`, `ev_ceb19ad83…`) exact steps: `FUN_0082ed00` + `FUN_0082e078` prologue, `FUN_0082f1c8` guard, `FUN_0082ec5c(map,x,y,buf4)` base 4 tags, then 2×2 loop calling `FUN_00830754(map,(x+i)*2,(y+j)*2,cell)` — the `*2` is the inset/half-texel sampling; dedup into `abStack_20`, bubble-sort, then per-tag mask `8/4/2/1` (`abStack_4c[0]==8`, `[2]==4`, `[1]==2`, `[3]==1`); single-tag or first-tag forces `0xf`. Calls `FUN_0082e2f4(map+0xa4,tag)` for art, branches on `*(art+0xc)` / `*(art+0xd)`.
- Base quad writer `FUN_00812b4c` at `0x812b4c` (`ev_6f767eede169f5e551f3e6d87ba59232f3797a7f9a051eed0af1dbeee1757755`): slot `(param_1&0xff)*0x48` under `*(param_12-4)`; UVs `u=param_9/param_3`, `v=param_8/param_11`, `u2=(param_10+param_9)/param_3`, `v2=(param_10+param_8)/param_11`; V-flip `v=_DAT_00812c90-v` when `param_6!=0`.
- Inset/alpha writer `FUN_00812ccc` at `0x812ccc` (`ev_e9694d0da085e0a3c3dcb0fb2d19548bbbdcffc6c3ac5fbbfad22c7e153b05db`): same `0x48` stride at `+0x25`; `u=param_9/param_3 ± *(param_12-8)`, `v=param_8/param_11 ± *(param_12-12)` with pattern `+insetX,+insetY / -insetX,+insetY / -insetX,-insetY / +insetX,-insetY`; V-flip via `_DAT_00812e30`.
- Alpha selectors: `FUN_0050daec` at `0x50daec` (`ev_d7e71e035e95ceaa9d011e3701bf6a2bfddb75cf69d7555b8edfe17c511bf207`): `return (DAT_008f5d00+(mask&0xff)*2)[variant&1]` — 16-entry 2-byte parity LUT at `0x8f5d00`. `FUN_0050db08` at `0x50db08` (`ev_70c790f9e5559ac103f7f30d4e7377be7f708044936848acffaaaa0d0879ffca`): `mask<0xf → DAT_008f5cd7[mask]`; `mask==0xf → DAT_008f5ce8[variant&1]` (plain) or binned `DAT_008f5cec[%6] / f2 / f6 / fa [&3]` by variant ranges when `param_3==1` (tsDouble/extended path).
- Record layout grounding: 24-byte head = 4 corner tags `+0..3`, variant `+4`, reserved `+5..7`, collision/tag `+8..23`; 13-byte tail corners/flags/override/mode/threshold/dirty; setter never writes tail; renderer may substitute `record13+8` via `0x830754/0x830818` when override active. [O/D] — `fnd_57`/`fnd_60` series.
- Built-in engine has no discovered function at `0x8326b8` / `0x830754` (`ev_a2ee858fdde53cc1b3a515896bdef8bee224ce7a36f449a513bc4fcfca646cde`, `ev_86e6d5785bbfa1c7c4d7ec47d3e10f014e47c512780cecd9ca24b222c97671c5`); Ghidra on-demand decompile is the only pseudocode source — 1 pass each, no bounds claim.
- Port fix: fetch 4 corners (via `0082ec5c` + `00830754*2` equivalents), dedup+sort ascending, build `8/4/2/1` mask in that corner order, force `0xf` on single/first, index `0x8f5d00`-semantics LUT by `(mask,variant&1)` for patch and `008f5cd7…` for alpha level; emit base quad + inset quad with `±insetX/±insetY` and V-flip flag; never use id-bit split.

## 6. Light products: sceneColor + material 0.15686 / 0.78125 [D/U]

- Task-given donor material pair `0.15686 (≈40/255)` / `0.78125 (=200/256)` matches field-material neutral `200/255` convention observed in `fnd_36` (warm `232,218,195`; field1..7/w neutral `200/255`; ambient+diffuse zero, emission carries color) and tree.pvl.id6 formula `tex0*(scene+lightAmbient+lightDiffuse)+specular` (`fnd_39`). Terrain path is lit `bmAlphaTest50/fcNoCull`-class with `GL_GEQUAL/GL_GREATER α ref 0.5` cut-out, not alpha blend (`fnd_43`, `ev_df9d…` correction chain; `fnd_42` DST_ALPHA factor correction for env decals only). [D]
- Native GL imports proving lighting/material/TMU stage exists (thunks only, no numeric products recovered): `glLightModelfv/i` `0x4afd24/0x4afd2c` (`ev_c09b48062274ba9812f0b2553d0b5971c3a3ac5193d707ea8`), `glMaterialfv/i` `0x4afd64/0x4afd6c` (`ev_72da5396984e745b1f14bc706b32633758209cee69dfe88dd1e3ff1a59e04cc1`), `glAlphaFunc` `0x4afc64` (`ev_db9d3316ba964890097dc1bc2d560ab07d3d44b27995ccbd4161816e53ad8a8b`), `glTexEnvi` `0x4afe44` (`ev_df9d50c9b7652a4759babe1dbdf570fe8361e6cc0ef43d4ce9b2d4c79175148a`), `glBlendFunc` `0x4afb14` (`ev_1ef91e406261feb3a7a4fc2010353bc6ff872be82d7733746b4b72be82d7abc3`). Exact sceneColor uniform address and per-material `0.15686/0.78125` store addresses NOT recovered in this pass. [U]
- Height-field shader shape (prior): ground UVs from `gl_EyePlaneS/T[0]` dot eye-space pos then `gl_TextureMatrix[0]`; binary setter uses default planes `S=(1,0,0,0) T=(0,1,0,0)`; face materials override scale `0.125` with eye-linear `X/Z` or `Y/Z` planes. [D] — `fnd_26` (`ev_97d7b661006591a1a4c9aeb0d7f244c0a3f34ab9eb0d257248eda100a5`, `ev_64eb217c56f50781fe8dfcea998a4d1ea16b97b00ec9d1ac9ad380cf95cfdee0`, `ev_27661ad31d177b3e546ccbb7b6761913f4c823d410d31334f28fe09e59`).
- Why port dulls: Blinn-Phong without `sceneColor` drops the `scene+ambient+diffuse` sum and specular term; with zero ambient/diffuse convention the port multiplies albedo by ~1.0 light and misses warm emission LUT, flattening saturated mottling to olive mean.
- Port fix: implement `color = tex0*(sceneColor+ambient+diffuse)+specular` with neutral `200/255 (0.78125-domain)` and `40/255 (0.15686-domain)` material slots as script-driven uniforms; add `sceneColor` uniform lookup (address TBD — do not hardcode); keep alpha-test `≥0.5/no-blend/two-sided` state.

## 7. Mip/filter `maNearest` / `miNearestMipmapLinear` [U]

- Pair is task-given donor sampler state; no `GL_*`/string literal recovered in exe (literal search `GL_` returns 0 strings, `ev_de08200bd75c3e77f8efab3d044d5162d91549ffe24518fcfd629012eb453d5f`; `maNearest`/`TextureMap`/`detail` all no-match in exe per `ev_4ba752…`, `ev_4d613f…`, `ev_648b2f1…` — expected: these names live in donor DScript/material text, not CODE). GL filter entry exists (`glTexParameteri` thunk `0x4afc4c`, `ev_4dc5427e122032a3affc35f683b738c3affc3369f0abf462bc9bf1a9060b7`), but enum args at call sites not traced in this pass. [U]
- Why port dulls: `maNearest` keeps block/subcell texels crisp; `miNearestMipmapLinear` blends only across mips (no intra-mip bilinear wash). Port trilinear/linear-mip averages the 8×8 mottling into olive at grazing angles and distance. Packed 128 px atlas compounds it with cross-block bleed; donor blocks are 1024 px (`+0x28` stride domain).
- Port fix: set mag `NEAREST`, min `NEAREST_MIPMAP_LINEAR`, generate full mip chain from 1024 px donor blocks (not 128 px pack); re-test `cZW0AEupCaI` at grazing angle before changing any shader math.

## 8. Why each approximation dulls color (summary)

| Port approx | Donor rule it replaces | Dulling mechanism |
|---|---|---|
| single tile id | 4 corner tags + sort + `8/4/2/1` mask + `0x8f5d00` LUT + insets (§5) | no mottled transitions; single olive mean per quad; black ground when detail ids forced through bit-split |
| packed 128 px atlas | per-`tiles.mat` 1024 px block + `+0x28` stride + 8×8 subcell (§2–3) | bleed + wrong `u=off/stride` scale; subcell frequency lost → regular lattice |
| id-hash alpha | `0050daec/0050db08` LUTs at `008f5d00/008f5cd7…` (§5) | wrong patch/inset per mask; hard seams replace feathered mottling |
| Blinn-Phong w/o sceneColor | `tex0*(scene+amb+dif)+spec`, neutral 200/255, warm emission, α-test 0.5 (§6) | missing product + emission; olive flattening; wrong blend state |
| detail bitmap off | 320×320 low/high, `h<0.1`, `floor(r*255) div 2`, id-0-only (§1) | missing high-frequency lush speckle |
| linear mips | `maNearest/miNearestMipmapLinear` from 1024 px (§7) | distance wash to olive-grey |
| smooth skipped/reordered | 3-pass H-then-V + file-order/distance/prob rule before detail (§1/§4) | hard single-color plates; 88% test8 ceiling reflects untested remainder, not quality proof |

## 9. Concrete port recommendations (no edits)

1. Implement 4-tag cell fetch (`82ec5c`-equivalent + `830754*2`-equivalent), dedup+ascending sort, `8/4/2/1` mask, `0xf` force rule; drive patch via `008f5d00`-semantics `(mask,variant&1)` and alpha via `008f5cd7…` semantics (`ev_d7e71e…`, `ev_70c790…`, `ev_ceb19ad8…`).
2. Emit two quads per layer exactly as `00812b4c`/`00812ccc`: base UVs over `param_3/param_11` stride with `00812c90`-flag flip; alpha quad with `±*(−8)/±*(−12)` insets and `00812e30`-flag flip; variant byte is Delphi-LCG high byte at `DAT_008f2008` (`state*0x8088405+1`, `Random(256)=state>>>24`), not DScript `RandomExt` (`fnd_56`, `fnd_64`).
3. Restore art path `0082e2f4` semantics (`ev_3498f84b…`): membership test → indexed fetch → default fallback; then branch on `+0xc/+0xd` type flags for plain vs `tsDouble` 8×8 (`%8`, `/8`, `+0x24/+0x28`, `+0x2d/+0x30/+0x2c`, `+0x1c/+0x20` insets).
4. Restore lighting product + state: `tex0*(sceneColor+ambient+diffuse)+specular`, neutral/warm emission slots, `GL_GEQUAL/GREATER ref 0.5` alpha-test, no-blend, two-sided (`fnd_36`, `fnd_39`, `fnd_42–43`); add `sceneColor` uniform (address open).
5. Restore samplers from 1024 px blocks: mag `NEAREST`, min `NEAREST_MIPMAP_LINEAR` with full chain (§7); confirm `hmapTex` anchor `VA 0x853e0c` / file `0x45320c` single ref at `0x853bde` (`ev_f517fe55…`, `fnd_7`) is water-only and not reused for terrain.
6. Restore order TextureMap → 3-pass Smooth (file-order/distance/prob) → conditional detail (id-0, `h<0.1`); keep `TileSmoothPasses=6` vs `SmoothTileMap(...,3)` contradiction open (`fnd_11`) — do not bake 6.
7. QA: re-run test8 plus grazing-angle `cZW0AEupCaI` capture comparing mottling macro-period (16 m), patch insets, and distance saturation; report remains no-parity.

## 10. Open unknowns [U]

- Numeric store addresses for `sceneColor`, `0.15686`, `0.78125`, `maNearest/miNearestMipmapLinear` enums, `_DAT_00812c90/_DAT_00812e30` flip constants, `006b1d0c/6b1d50→82ec5c/8326b8` wrapper confirmation beyond opcode walk, and generation-time Delphi-LCG seed (`QueryPerformanceCounter/GetTickCount` reseed unverified, `fnd_56`).
- `TerrainMapBegin/End`, `TextureMap`, `SmoothTile*`, `tsDouble`, `maNearest` live in donor script/material text — exe literal absence (`ev_4d613f…`, `ev_f07179…`, `ev_7c1d8ae8…`, `ev_4ba752…`) is not refutation.
- Prior `fnd_25` SRC_ALPHA vs corrected DST_ALPHA (`fnd_42`): terrain cut-out unaffected; env-decal path only.
