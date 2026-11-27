---
id: PORT1TO1-TERRAIN-RENDERER
ticket: "TERRAIN-SWARM-2026-11-26 / PORT1TO1-RENDER — exact donor terrain rendering pipeline, implementable spec"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_renderer.md
targets:
  - "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0 (sha256 87f0f3c130b027e7…)"
  - "C:\\Games\\Cossacks 3\\editor.exe — t_68474ddde43f (pinned, not re-read this pass)"
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor executable run, copied, committed or modified. No repo code/shader/config/asset/test/git/Godot edit. Craft Anything native/text tools used with explicit document: pins; global active target was never opened or switched. Exactly one repo file written: this report."
---

# PORT1TO1-RENDER — exact donor terrain renderer, implementable specification

## 0. Executive summary — the pipeline in one pass

The donor does **not** render one quad per map cell from one tile id. It runs a
**per-cell layer producer** that emits **1–4 textured quads**, each with an
explicit RGB UV pair and an explicit alpha UV pair baked into the display list.
Every numeric selector is either a byte in the cell record, a byte in a
material descriptor, or a byte in a fixed table in `cossacks.exe`. The complete
chain recovered/verified here is:

```
per map cell (x,y):
  1. read 24-byte record -> tags[4], variant@+4           [O] 0x82ec5c, ev_f505b1a3…
  2. 2x2 override lookup at (2x,2y)..(2x+2,2y+2)          [O] 0x830754, ev_58d7418c…
     -> final tags[4] = {t0=8,t1=2,t2=4,t3=1}
  3. distinct-unique + ascending bubble sort              [O] 0x813055–0x8130fc
  4. per distinct tag, ascending, one layer:
       mask = 8*[tag==t0] + 4*[tag==t2] + 2*[tag==t1] + 1*[tag==t3]
       if single distinct or first (base) layer: mask = 0xf
       if scheme==tsSingle:
           art = lookup(tag)                              [O] 0x82e2f4, ev_3498f84b…
           rgbIndex = RGB_LUT[mask] or FULL_VARIANT[...]  [O] 0x50db08, ev_70c790f9…
           uv0 = subcell(rgbIndex)                        [O] 0x812b4c, ev_6f767eed…
       if scheme==tsDouble (shipped):
           uv0 = ((x+W/2) mod Rows, (y+H/2) mod Rows)     [O] 0x813235–0x8132c3
           alphaIndex = ALPHA_LUT[mask, variant&1]        [O] 0x50daec, ev_d7e71e03…
           uv1 = subcell(alphaIndex) + base-only insets   [O] 0x812ccc, ev_e9694d0d…
       emit 4 vertices per layer                          [O] 0x818920 / 0x818428,
                                                              ev_ec93f0af… / ev_696bc518…
  5. fragment: rgb = texUnit0(uv0), a = texUnit1(uv1),
     rgb = rgb*(sceneColor+ambient+diffuse) + specular,  [O] hf.pvl.sm.vert / .smx3.frag
     gl_FragColor = vec4(rgb, a)
  6. fixed-function bmTransparency over an already-drawn
     base layer: glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA), GL_FUNC_ADD
                                                          [O]/[D] 0x4ef991 / 0x88fb78 / 0x8fb1ac
```

Everything in that chain is byte-proven or text-proven. The remaining `[U]`
items are **runtime bindings that no static read can settle**; §9 gives a
concrete decomp/instrument plan for each, never "accept approximation".

**Three material corrections to prior reports are made in this pass** (§10):

1. **DEC-VIS-01 §5.4 transposed the alpha UV axes.** The code computes
   `u = floor(p/AlphaCols)/AlphaRows`, `v = (p mod AlphaCols)/AlphaCols`, not
   `u=(p%4)/8, v=(p/4)/4`. Consequently `p+16` shifts **u by +0.5** (four
   columns right), it does **not** add 1.0 to v; the "parity half is
   repeat-equivalent" claim is **withdrawn**.
2. **`DEC_DEEP_corner_tags` / `DEC_VIS_04` 13-byte template anchor `0x8fab6c`
   is not a 13-byte record.** At `0x8fab6c` the bytes are a pointer-like table
   (`ev_d12329f0…`, `ev_3425045d…`); the only 9 byte-exact `00*10 ff ff 00`
   13-byte defaults in the file are in `.rsrc` (`ev_ff4fffbe…`). The runtime
   record13 default address is **[U]**.
3. The RGB "full-variant" tables are **six distinct byte ranges**, not one:
   `0x8f5ce8` (2 B), `0x8f5cec` (6 B), `0x8f5cf2`/`f6`/`fa` (4 B each),
   with a final implicit `return 0` (`ev_70c790f9…`, `ev_a03439ea…`).

No donor parity claim is made. No donor GPU A/B frame exists.

---

## 1. Target discipline and method

- Every native call used an explicit `document:` pin: `t_87f0f3c130b0`
  (`cossacks.exe`) and, where a second build was needed only by prior reports,
  `t_68474ddde43f` (`editor.exe`). `native_document_show` confirmed the pinned
  identity: `ev_db6bfd63…-class` result
  `{document:"t_87f0f3c130b0", name:"cossacks.exe", sha256:"87f0f3c130b0…"}`.
- `core_session_show` at start: `analysis_mode = deep`, `clean_room = false`,
  `active_target = null`, `targets = []`. **This worker issued no
  `core_target_open`/`select`**; every native call used an explicit `document:`
  pin. A final `core_session_show` later in the shared session reported
  `active_target = t_87f0f3c130b0`, `targets = [t_87f0f3c130b0, t_68474ddde43f]`
  — that change came from a **concurrent worker**, not from this agent; it does
  not alter any evidence id or address cited here (all were pinned explicitly).
- Donor material was inspected as bytes/disassembly/text only; no donor binary
  was executed, copied, committed or modified. `native_*` read tools and
  `core_text_read` are read-only.
- Starting documents re-read in full: `DEC_VIS_01_uv_mapping.md`,
  `DEC_DEEP_terrain_color_quality.md`, `DEC_DEEP_corner_tags.md`,
  `DEC_SMALL_cell_rotation_flip.md`, `DEC_SMALL_light_products.md`, `D08`,
  `F06`, `X17`, `X35`; current `variant3d/shaders/terrain_donor_shader.gdshader`
  (568 lines) and `variant3d/scripts/terrain_donor_mesh.gd` (1532 lines).

### Multi-pass ledger

| Lead | Pass 1 | Pass 2 | Pass 3 | Accepted |
|---|---|---|---|---|
| Alpha LUT | raw 256 B @ `0x8f5d00` (`ev_8d1f6535…`) | `FUN_0050daec` pseudocode (`ev_d7e71e03…`) | cross-check F06 constant patches (4,0)/(7,3) | 16 pairs, p+16 = +4 columns |
| RGB LUT / full-variant | raw 256 B @ `0x8f5cd7` (`ev_a03439ea…`) | `FUN_0050db08` pseudocode (`ev_70c790f9…`) | raw 256 B @ `0x8f5ce8` (`ev_48626c09…`) | 5 tables + implicit 0 |
| Producer | Deep `FUN_00812e34` (`ev_ceb19ad8…`) | full 516-insn disassembly (`ev_58d7418c…`) | UV writers (`ev_6f767eed…`, `ev_e9694d0d…`) | mask/sort/8×8/insets exact |
| Rotation constants | `DEC_SMALL_cell_rotation_flip` raw pushes | re-read `0x813210/2ac/36a` push bytes | flip constants `0x812c90/0x812e30` = 1.0f (`ev_1db801be…`, `ev_47db71da…`) | DEC_SMALL confirmed |
| Vertex emission | `FUN_00818428` pseudocode (`ev_696bc518…`) | raw `0x818428` disassembly (`ev_696bc518…` assembly) | `FUN_0081ac98`/`FUN_00818920` (`ev_ec93f0af…`) | units `0x84c0/0x84c1`, `glVertex4f` |
| Lighting | `hf.pvl.sm.vert`/`smx3.frag` full text (`ev_83d90ad0…`, `ev_11224700…`) | `light.cfg` (`ev_ed96da32…`) | `reftile.mat`/`reftilealpha.mat`/`colors.lib`/`shaders.lib` (`ev_fadb2880…`, `ev_c949cdfc…`, `ev_d6da102c…`, `ev_80043e7b…`) | equation + all numbers from TEXT, not CODE |
| Blend/alpha-test | prior X17/D08 byte reads | raw `0x4ef991/0x88fb78/0x8fb1ac` (X17 ids) | donor fragment full read (no mask multiply) | factors exact, pass count [U] |
| 13-byte default | prior `0x8fab6c` claim | raw 16 B @ `0x8fab6c` (`ev_d12329f0…`) | `native_bytes_find 000…ffff00` (`ev_ff4fffbe…`) | 9 `.rsrc` only → runtime anchor [U] |

---

## 2. Evidence register

### 2.1 New in this pass (all `document: t_87f0f3c130b0` unless noted)

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_db6bfd630abc6ca200c56e183c715c7e754ce81bfc3af8b3bf63c60d26874476` | `native_address_offset_show 0x8f5d00` | VA `0x8f5d00` = file `0x4f4f00`, section DATA |
| `ev_a03439ea3ea612d344359fe1723f1b1b262ace81239d74e8d295987dc05b2c7f` | `native_bytes_show 0x8f5cd7`, 256 B | RGB mask LUT + all full-variant tables (§3.5) |
| `ev_8d1f653525637e05ea0747c014c7b149a6174e05e3982d9528dc516e1432a9f3` | `native_bytes_show 0x8f5d00`, 256 B | 16 alpha pairs + pointer tail (§5.2) |
| `ev_48626c09dd24c5da7dc943d14044b9fc622842b7c6fb10edfbac920be62846f7` | `native_bytes_show 0x8f5ce8`, 256 B | plain/full/binned table bytes |
| `ev_ced999a44ba36352b686cb265e4175e6c032202afbaa442a492b56ea3215d6a5` | `native_data_show 0x8f5ce6` | filler u32 `0x0f00c08b` between tables (padding, not a selector) |
| `ev_70c790f9e5559ac103f7f30d4e7377be7f708044936848acffaaaa0d0879ffca` | Deep `FUN_0050db08` | exact RGB selector incl. `param_3` switch and four variant bins |
| `ev_d7e71e035e95ceaa9d011e3701bf6a2bfddb75cf69d7555b8edfe17c511bf207` | Deep `FUN_0050daec` | `pair[(mask&0xff)*2][variant&1]` |
| `ev_ceb19ad83d1757d17a40c3bf90f356b087c69d4795c476afc868385529b0a657` | Deep `FUN_00812e34` | 324-line producer: 2×2 override, dedup, sort, mask, both UV paths |
| `ev_58d7418c2dc5d46b793f64c408ea8a2f834ee5020be74b51d7c80968ff420221` | `native_function_disassemble 0x812e34` | raw mask compares `+8/+4/+2/+1`, scheme branch `0x813155`, all push constants |
| `ev_3498f84b3633e914cc87f5f18981bf92c7a7ef32eaca8d5b29460bc36f8672e5` | Deep `FUN_0082e2f4` | art lookup: count/membership/index/default fallback |
| `ev_6f767eede169f5e551f3e6d87ba59232f3797a7f9a051eed0af1dbeee1757755` | Deep `FUN_00812b4c` | RGB 4-corner writer, `0x48` stride, `v:=1-v` at `_DAT_00812c90` |
| `ev_e9694d0da085e0a3c3dcb0fb2d19548bbbdcffc6c3ac5fbbfad22c7e153b05db` | Deep `FUN_00812ccc` | alpha 4-corner writer, `+0x25` stride, `±insetX/±insetY`, `v:=1-v` |
| `ev_b2e664174e17999a7e990a22fcbd872ac88c7f39a259053d684bbf0859075438` | Deep `FUN_00544548` | descriptor field map `+0xc/+0xd/+0x1c/+0x20/+0x24/+0x25/+0x28/+0x2c/+0x2d/+0x30/+0x34/+0x38` |
| `ev_1db801beaac6c3119181cc9d0a5833cb4d5938a9581281d219431f5f4c76effb` | `native_data_show 0x812c90` | `0x3f800000` = 1.0f |
| `ev_47db71da537ecf4e1ad8428b47bc655ec6c45488796d0441b8661ab1e38c65c7` | `native_data_show 0x812e30` | `0x3f800000` = 1.0f |
| `ev_ec93f0af1fb49a1db65615047d264009071a024bf9acd83e8870e7a2b8e11b91` | Deep `FUN_00818920` | mesh/display-list builder; calls cell callback; boundary skip via `0x82f1c8` |
| `ev_696bc518d0ab6b3b28c3d5997b93c734f980524c68d7230ca5cbd2153cd30417` | Deep+raw `FUN_00818428` | `glMultiTexCoord2f(0x84c0,…)`, `(0x84c1,…)`, `glNormal3fv`, `glVertex4f(x,y,z,1)` |
| `ev_208b3390071b3de605c0cef1d0f4e4f006bec5976cf64e7a112518da8d28af3e` | Deep `FUN_00403a0c` | `state = state*0x8088405+1; return (n*state)>>32` |
| `ev_3b31d24a34caad9daca2308f35a4a5f3ac11d50aa466256be09dcb885310f750` | `native_bytes_show 0x8f6164`, 24 B | record24 default: 4 tags 0, variant 0, 3 reserved 0, four `1.0f` |
| `ev_d12329f0f5457a234571bd9a18612b7f7a2e138be99aa672583dbbb1c0e31403` | `native_bytes_show 0x8fab6c` | bytes are pointer-like, not a clean 13-byte default |
| `ev_e20be9505dc75a7160698715f9f412e11032ba2f0b65e9aececbdfd16d76abc0` | `native_data_show 0x8fc33c` | pointer[512]; first target `0x8f6164` (24-byte default) |
| `ev_3425045df02872329da13e8f342cd275c40d1c1224d6967b32f7845d2081a6b2` | `native_data_show 0x8fab6c` | inferred u32 = 0; no record13 type recovered |
| `ev_ff4fffbe88eec1be2c82c96badef0b97aadcbd7312da0f9a89ebb3802914099a` | `native_bytes_find` 13 B | `00*10 ff ff 00` occurs 9×, **all in `.rsrc`** |
| `ev_83d90ad0d5cfc53c272e6c79d18ea537016db4f900c4c386d77e3f9c04c7c52c` | `core_text_read hf.pvl.sm.vert` | full 50-line lighting/texgen vertex program |
| `ev_1122470077454cdfb1fc1c5b9ac1b953c2f0411d98738d9ce64207a779f18e4f` | `core_text_read hf.pvl.smx3.frag` | full fragment: 2 samplers, packed light, 3-tap PCF, 4 fog modes |
| `ev_ed96da32e89d1b6529a69d7c6ef8e0a4b79181ac906da9cb32da4f34ea147a83` | `core_text_read light.cfg` | active sun + light colours + `lsParallel` |
| `ev_fadb2880f0f4e7dd3f2c25aae03687964c0ab399ae206c72d1c8e7c7d00b96cd` | `core_text_read reftile.mat` | material 0.15686/0.78125/0/0/16; filters; face refkeys |
| `ev_c949cdfcb7df3d87260f8cab96fee7b152c5cde66cd077cf4e9566927a9279d3` | `core_text_read reftilealpha.mat` | alpha/alphavert/alphanull materials, `tiaAlphaFromIntensity` |
| `ev_0290fb402dede43a839fe7bdd068f63c46d6a26a1dba1bbd4ef58f376549111f` | `core_text_read reftile.lib` | `tsDouble`/`ttExtended`, insets 0.1/0.2 |
| `ev_80043e7bf61b2f008364d06db3c5087c068f88e644675190e94158395a155c4b` | `core_text_read shaders.lib` | HeightField binds `texUnit0=0`, `texUnit1=1`, `texGen=true` |
| `ev_d6da102c8c9cdd531fb3cb180a63be12766d7322c61be88bda8bc2c0744d5b52` | `core_text_read colors.lib` | fog/shadow palette numbers, `FogMode=0` |

### 2.2 Reused from cited reports (still valid, not re-derived)

`ev_aacd864e…` / `ev_81b6d7f6…` (24 B + 13 B reader/writer), `ev_1448daf1…`
(24 B getter stride `0x18`), `ev_a0fffbc4…` (four `u32` at `+8..+0x17`),
`ev_723448b3…` (13 B getter stride `0x0d`), `ev_1d5e6e86…` /
`ev_27273f21…` (constructor + scheme table), `ev_9ce28a17…` (callback install),
`ev_8ed2a809…` (single-UV path), `ev_97d7b661…` / `ev_1a116a59…` /
`ev_bfb3fda2…` (texgen + identity matrix), `ev_0e2c2919…` / `ev_5563aa24…`
(editor.exe byte-identical LUTs), `ev_4be0c95b…` / `ev_58eb274e…` (flip
constants), `ev_ef6544a2…` / `ev_4d202b29…` (`GL_SRC_ALPHA`/`GL_ONE_MINUS_SRC_ALPHA`),
`ev_5071f34e…` / `ev_45ddf934…` / `ev_2c730d46…` (blend setter bytes),
`ev_3f19390c…` / `ev_f9fc8845…` (light/material state uploaders),
`ev_3498f84b…` (art lookup), `ev_1d5e6e86…` (8×8 defaults),
`ev_58d7418c…`/`ev_e9694d0d…`/`ev_224b851c…` (DEC-VIS-01 chain),
`fnd_56`/`fnd_64` (Delphi LCG seed stream), `fnd_36`/`fnd_39`/`fnd_42–43`
(field/tree light products and alpha-test classes).

---

## 3. Per-cell data required

### 3.1 On-disk / in-memory records

Two interleaved arrays exist per terrain object (`FUN_008302b0` reader
`ev_aacd864e…`, `FUN_008305a0` writer `ev_81b6d7f6…`):

| Array | Stride | Source field | Contents |
|---|---:|---|---|
| `record24` | `0x18` (24 B) | terrain `+0x14` row-pointer table | `+0..+3` four `u8` corner tags; `+4` variant/random byte; `+5..+7` reserved/sentinel `[U]`; `+8..+0x17` four `u32` collision/tag words (the recurring `1.0f` pattern is **not** proven to be blend weight — `sub_82ebc0` `ev_a0fffbc4…`, DScript `collision[4]`) |
| `record13` | `0x0d` (13 B) | terrain `+0x20` row-pointer table | `+0..+3` four `s8` values; `+4..+7` four `u8` corner flags (2×2 bitmap, index `(subrow&1)*2+(subcol&1)`); `+8` override tile id; `+9` override random; `+10/+11` signed control/threshold (default `0xff` per prior reports); `+12` loaded/dirty flag (reader sets 1, writer clears 0) |

Byte-exact `record24` default (`0x8f6164`, `ev_3b31d24a…`):
`00 00 00 00 00 00 00 00 | 00 00 80 3f ×4` — four zero tags, variant 0,
three zero reserved bytes, four `1.0f` words. The pointer table `0x8fc33c`
(target `0x8f6164`, `ev_e20be950…`) is the OOB default used by `sub_82ec5c`.

**Correction [D]:** the 13-byte default template is **not** at `0x8fab6c`.
Raw bytes there (`ev_d12329f0…`) are pointer-like and `native_data_show`
types them as u32 0 (`ev_3425045d…`). A 13-byte `00*10 ff ff 00` pattern
occurs 9 times in the file, **all in `.rsrc`** (`ev_ff4fffbe…`), so no loaded
DATA-section 13-byte default template was recovered in this pass. The serialized
*layout* above is proven by reader/writer/getter; the template *address* is
**[U]** (§9, U-9).

### 3.2 Corner tag order and the 2× override substitution

The producer reads 24 B via `FUN_0082ec5c(map,x,y,buf)` at `0x812fca` into a
4-tag buffer at `[ebp-0x48]` (raw `ev_58d7418c…`). It then **overwrites** those
four tags in a 2×2 loop (`0x812fd6–0x813053`) calling
`FUN_00830754(map, (x+b)*2, (y+a)*2, cell)` — the coordinate doubling is the
donor's half-cell/inset subcell probe, and `0x830754` applies the `record13+8`
object override only when the `terrain+0xa4` gate fires (`DEC_DEEP_corner_tags`
§7.4). So the **final** tags used by the renderer are the override-resolved
ones, at doubled coordinates.

Corner index and mask weight are byte-proven at `0x813125–0x813145`
(`ev_58d7418c…`):

| Corner | Buffer slot | Mask bit | Raw compare |
|---|---:|---:|---|
| `t0` | `+0` (`[ebp-0x48]`) | `8` | `cmp al,[ebp-0x48]` → `add [ebp-0x20],8` |
| `t1` | `+1` (`[ebp-0x47]`) | `2` | `cmp al,[ebp-0x47]` → `add …,2` |
| `t2` | `+2` (`[ebp-0x46]`) | `4` | `cmp al,[ebp-0x46]` → `add …,4` |
| `t3` | `+3` (`[ebp-0x45]`) | `1` | `cmp al,[ebp-0x45]` → `inc …` |

This is the authoritative order for any port: **`t0=8, t1=2, t2=4, t3=1`**
(DEC-VIS-01 §5.2 wrote them in compare order 8/4/2/1; both describe the same
bits, but the slot↔bit pairing above is the raw one).

**Tag creation (setter):** `0x8326b8` stamps one scalar `u8` into corner
`a*2+b` of each in-bounds cell `(r-a,c-b)`, `a=0..1`, `b=0..1`, with bounds on
the *target* cell via `0x50fba0`; one Delphi `Random(256)` draw per accepted
write is stored at `record+4` (`DEC_DEEP_corner_tags` §3/§6, re-confirmed by
`FUN_00403a0c` pseudocode `ev_208b3390…`). There is **no** per-cell rotation,
face branch or LUT in the setter.

### 3.3 Variant byte source — exact

`FUN_00403a0c(n)` (`ev_208b3390…`):

```c
DAT_008f2008 = DAT_008f2008 * 0x8088405 + 1;   // mod 2^32
return (uint)((ulonglong)n * (ulonglong)DAT_008f2008 >> 0x20);
```

Called with `n=0x100` at `0x832722` → `byte = state >>> 24`. One draw per
accepted cell write; the final `+4` byte is the last writer's draw. Image
state reads 0 (`ev_4f8831fd…`); generation-time reseed is `[U]` (§9 U-3).
`0x81272f` is **not** a variant byte — it disassembles as garbage
(`DEC_DEEP_corner_tags` §6.2). DScript `RandomExt` is a **different** stream.

### 3.4 Dedup + sort + mask (producer body, `ev_ceb19ad8…`)

```c
// 0x813055–0x8130b4: unique 4 tags into abStack_20 (iStack_18 = count)
for each of 4 corners: if not already in distinct[], distinct[count++] = tag;
// 0x8130b6–0x8130fa: ascending bubble sort of distinct[0..count-1]
for (i=0..count-2) for (j=i+1..count-1) if (distinct[j] < distinct[i]) swap;
// 0x81311a–0x813145: per distinct tag (ascending), [ebp-0x20] = mask
mask = 0;
if (tag == t0) mask += 8;
if (tag == t2) mask += 4;
if (tag == t1) mask += 2;
if (tag == t3) mask += 1;
if (count == 1 || layer_index == 0) mask = 0xf;   // 0x813167 base/full rule
```

Variant byte is read from `[ebp-0x44]` = `buf+4` and passed to both LUTs.
Layer count = number of distinct tags, **1–4**. Schemes are selected by
`[edi+0xc]` at `0x813155`: `0 → 0x813167` (tsSingle mask path),
`1 → 0x813235` (tsDouble path), `≥2 → skip` (raw `ev_58d7418c…`).

### 3.5 Full table dump and LUT arithmetic (addresses exact)

**RGB mask table** `DAT_008f5cd7`, 15 bytes (`ev_a03439ea…`):

| mask | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| index | 46 | 4 | 8 | 12 | 1 | 5 | 9 | 13 | 2 | 6 | 10 | 14 | 3 | 7 | 11 |

**Full-variant tables** (from `FUN_0050db08`, `ev_70c790f9…`; bytes
`ev_a03439ea…`/`ev_48626c09…`). Let `m=mask`, `v=variant`, `t=param_3` (the
descriptor byte `+0xd`, TileType; `1` = ttExtended):

| Address | Length | Bytes | Used when |
|---|---:|---|---|
| `0x8f5ce8` | 2 | `00 0f` = `[0,15]` | `m==15 && t==0` → `[v&1]` (plain full cell) |
| `0x8f5cec` | 6 | `00 0f 10 11 12 13` = `[0,15,16,17,18,19]` | `m==15 && t==1 && v<0x88` → `[v%6]` |
| `0x8f5cf2` | 4 | `14 15 16 17` = `[20,21,22,23]` | `m==15 && t==1 && v>=0x88 && ((v+0x78)&0xff)<0x44` → `[v&3]` |
| `0x8f5cf6` | 4 | `18 19 1a 1b` = `[24,25,26,27]` | previous fails and `((v+0x34)&0xff)<0x22` → `[v&3]` |
| `0x8f5cfa` | 4 | `1c 1d 1e 1f` = `[28,29,30,31]` | previous fails and `((v+0x12)&0xff)<0x12` → `[v&3]` |
| implicit | — | `0` | `t==1`, `m==15`, none of the four bins match |

Exact selector:

```c
undefined1 RGB_index(mask, variant, tileType) {          // 0x50db08
  r = 0;
  if (tileType == 0) {
    if (mask < 15) r = DAT_008f5cd7[mask];
    if (mask == 15) r = DAT_008f5ce8[variant & 1];
  } else if (tileType == 1) {
    if (mask < 15) r = DAT_008f5cd7[mask];
    if (mask == 15) {
      if (variant < 0x88) r = DAT_008f5cec[variant % 6];
      else if ((u8)(variant+0x78) < 0x44) r = DAT_008f5cf2[variant & 3];
      else if ((u8)(variant+0x34) < 0x22) r = DAT_008f5cf6[variant & 3];
      else if ((u8)(variant+0x12) < 0x12) r = DAT_008f5cfa[variant & 3];
    }
  }
  return r;
}
```

The `8b c0` u32 words at `0x8f5ce6`, `0x8f5cea`, `0x8f5cfe` (`ev_ced999a4…`)
are **padding between byte tables**, not selectors — do not index them.

**Alpha table** `DAT_008f5d00`, 16 little-endian pairs (`ev_8d1f6535…`):

| m | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| pair (hex) | `0010` | `0212` | `0111` | `0313` | `0818` | `0a1a` | `0919` | `0b1b` | `0414` | `0616` | `0515` | `0717` | `0c1c` | `0e1e` | `0d1d` | `0f1f` |
| v&1=0 | 0 | 2 | 1 | 3 | 8 | 10 | 9 | 11 | 4 | 6 | 5 | 7 | 12 | 14 | 13 | 15 |
| v&1=1 | 16 | 18 | 17 | 19 | 24 | 26 | 25 | 27 | 20 | 22 | 21 | 23 | 28 | 30 | 29 | 31 |

```c
u8 ALPHA_index(mask, variant) {                           // 0x50daec
  u16 pair = *(u16*)(0x8f5d00 + (mask & 0xff)*2);
  return (variant & 1) ? (pair >> 8) : (pair & 0xff);
}
```

Bytes after `0x8f5d20` are a **pointer table** (`c0 1e 51 00 …`,
`ev_8d1f6535…`), not more patch indices.

---

## 4. RGB layer selection

### 4.1 Art lookup `0x82e2f4` (`ev_3498f84b…`)

```c
int art = FUN_0082e2f4(materialTable /* terrain+0xa4 */, tag) {
  n = FUN_0082e3dc(table);                    // count
  if (!FUN_0082e064(tag, 0, n-1))             // membership test
    return *(int*)(table + 0x18);             // default descriptor
  d = FUN_0089df30(*(int*)(table + 0x10), tag);
  return d ? d : *(int*)(table + 0x18);        // indexed fetch, default fallback
}
```

The port must resolve `tag → terrain.presets name → tiles.mat
Material.Texture.image`, with `tiles.lib` geometry overrides, and **must not**
use the 16×8 packed id atlas as a donor layout (`D08` §3.1/§5.2; `ev_e742a78…`).
112 shipped 1024² DXT1 blocks with 11 mips are the art units.

### 4.2 Descriptor field map (loader `FUN_00544548`, `ev_b2e66417…`)

| Offset | Meaning | Default / source |
|---:|---|---|
| `+0xc` | TileScheme (`0=tsSingle`, `1=tsDouble`) | `TileScheme` string |
| `+0xd` | TileType (`0=ttUsual`, `1=ttExtended`) | `TileType` string; drives RGB selector `param_3` |
| `+0x10` | block path | `param_1+0x20+4` |
| `+0x14` | block name | `TileBlockName` |
| `+0x18` | default descriptor pointer | `FUN_00544210`/`FUN_005444f8` |
| `+0x1c` | TileXOffset (f32) | `0.001953125` usual / `0.00390625` extended; `reftile.lib` overrides to **0.1** |
| `+0x20` | TileYOffset (f32) | default as above; `reftile.lib` overrides to **0.2** |
| `+0x24` | Rows (u8) | 4 (single/usual), 8 (single/extended), **8** (double) |
| `+0x25` | Cols (u8) | 4, 4, **8** |
| `+0x28` | TileSize (u32) | `0x40` = 64 |
| `+0x2c` | AlphaRows (u8) | 8 |
| `+0x2d` | AlphaCols (u8) | 4 |
| `+0x30` | AlphaTileSize (u32) | `0x40` = 64 |
| `+0x34/+0x38` | AngleX/AngleZ | 25 |

`reftile.lib` (`ev_0290fb40…`) activates `tsDouble/ttExtended`, offsets
0.1/0.2; the commented `Rows=16/Cols=16` are **inactive**. Constructor
defaults (`ev_1d5e6e86…`, `ev_27273f21…`) agree.

### 4.3 `tsDouble` RGB subcell — raw arithmetic (`ev_58d7418c…`, `0x813235–0x8132c3`)

Note the **second** `Round()` uses `param_3` (y) and the **first** uses
`param_2` (x); both divide by the **same** byte `[edi+0x24]` (Rows), not by
`+0x25`:

```c
xpx = ((Round(x) + (W >> 1 arithmetic)) % (u8)(art+0x24)) * (u32)(art+0x28);
ypx = ((Round(y) + (H >> 1 arithmetic)) % (u8)(art+0x24)) * (u32)(art+0x28);
// then FUN_00812b4c(slot, art+8, TileSize, …, xpx, ypx, TileSize, Vstride, …)
// u0 = xpx / TileSize = (x + W/2) mod Rows
// v0 = ypx / TileSize = (y + H/2) mod Rows
```

`Round` is `FUN_004a6a5c` (x87 `fistp`, process rounding). With Rows=8 and
`gc_meters_to_tile=2` (`D08` §3.6), the art matrix period is `8×2 = 16 m`.
The port's `fract(worldXZ*0.5)` repeats one art cell every 2 m and is the
structural cause of the regular lattice (`DEC_VIS_01` §10.1).

For `tsSingle`, the RGB subcell comes from `RGB_index(mask,variant,tileType)`:

```c
row = (index / (u8)(art+0x25)) * (u32)(art+0x28);   // +0x25 = Cols
col = (index % (u8)(art+0x25)) * (u32)(art+0x28);
```

### 4.4 Base corner order, rotation, mirror, V-flip (byte-proven)

`FUN_00812b4c` (`ev_6f767eed…`) writes to
`*(param_12-4) + (slot&0xff)*0x48`, four UV pairs at `base+5+corner*8`:

```
corner 0: (xpx,ypx)        corner 1: (xpx+TileSize, ypx)
corner 2: (xpx+TileSize, ypx+Vstride)   corner 3: (xpx, ypx+Vstride)
u = px / param_3;  v = py / param_11;  if (flip) v = _DAT_00812c90 - v;
```

Corner helper `FUN_00812b14`: `slot = (corner+rot)&3`, and if mirror
`slot = 3-slot`. `_DAT_00812c90 = 1.0f` (`0x3f800000`, `ev_1db801be…`).

The three UV-emit call sites in `FUN_00812e34` push literal immediates
(raw `ev_58d7418c…`; agrees with `DEC_SMALL_cell_rotation_flip`):

| Layer | Call | pushed consts (first→last) | mirror | V-flip | rot | mapping |
|---|---|---|---:|---:|---:|---|
| RGB mask/full (`tsSingle`) | `0x813227 → 0x812b4c` | `0,1,0,0` | 0 | 1 | 0 | identity; `v := 1-v` |
| RGB `tsDouble` | `0x8132c3 → 0x812b4c` | `0,0,1,0` | 1 | 0 | 0 | `slot = 3-corner`; no V-flip |
| Alpha `tsDouble` | `0x813380 → 0x812ccc` | `2,1,0,1` | 0 | 1 | 2 | `slot = (corner+2)&3`; `v := 1-v` |

**There is no per-cell rotation metadata** in either record; the 13-byte record
has no consumer at these sites (`DEC_SMALL_cell_rotation_flip` §4). The random
byte feeds only the patch LUTs, never rotation.

---

## 5. Alpha layer

### 5.1 Patch-inlet arithmetic — exact, with correction

`FUN_00812ccc` (`ev_e9694d0d…`) writes to
`*(param_12-4) + (slot&0xff)*0x48 + 0x25`, four UV pairs at `+0x25+corner*8`:

```
corner 0: u = xpx/param_3 + insetX,  v = ypx/param_11 + insetY
corner 1: u = (xpx+w)/param_3 - insetX,  v = ypx/param_11 + insetY
corner 2: u = (xpx+w)/param_3 - insetX,  v = (ypx+h)/param_11 - insetY
corner 3: u = xpx/param_3 + insetX,  v = (ypx+h)/param_11 - insetY
if (flip) v = _DAT_00812e30 - v;        // 1.0f, ev_47db71da…
insetX = *(float*)(param_12-8);  insetY = *(float*)(param_12-0xc);
```

In the producer, insets are loaded at `0x813330–0x813345` from
`art+0x1c` (TileXOffset **0.1**) and `art+0x20` (TileYOffset **0.2**) **only
when `mask==0`** (base/first layer); otherwise both are zero. Transition
layers have zero inset. No donor code clamps, floors or guards these insets.

The raw call (`0x813348–0x813380`, `ev_58d7418c…`) passes, in cdecl order:
`param_3 = 512 = AlphaRows(8)*AlphaTileSize(64)`, `param_8 = ((p%AlphaCols)*64)`,
`param_9 = ((p/AlphaCols)*64)`, `param_10 = 64`, `param_11 = 256 =
AlphaCols(4)*AlphaTileSize(64)`. Therefore, with `p = ALPHA_index(mask,variant)`:

```c
col = p / (u8)(art+0x2d);        // p / AlphaCols (= p/4)
row = p % (u8)(art+0x2d);        // p % AlphaCols (= p%4)
u0 = col / (u8)(art+0x2c);       // col / AlphaRows (= col/8)
v0 = row / (u8)(art+0x2d);       // row / AlphaCols (= row/4)
u1 = (col+1)/8;  v1 = (row+1)/4;
```

**Correction [D] to DEC-VIS-01 §5.4:** that report wrote
`x=(p%4)*64; u=x/512; y=(p/4)*64; v=y/256`, i.e. `col=p%4, row=p/4`. The raw
call above shows the opposite: `u` numerator is `p/AlphaCols`, `v` numerator
is `p%AlphaCols`. Consequences:

- `p+16` increments `col` by 4 ⇒ **`u += 0.5`**, not `v += 1.0`. The DEC-VIS-01
  claim "parity half is repeat-equivalent under `twBoth`" is **withdrawn**.
- Independent confirmation from F06 patch means (`ev_d7e71e…` chain; F06 §3.2):
  mask 2 gives p=2 → (col 0,row 2) mean **56.5**, p=18 → (col 4,row 2) mean
  **58.3** — two *different* patches, not a repeat. mask 1: p=1 → (0,1)=45.6,
  p=17 → (4,1)=82.8. The four authored sentinels also fit exactly:
  p=0 → (0,0)=255, p=16 → (4,0)=255, p=15 → (3,3)=0, p=31 → (7,3)=0
  (F06-E10). The transposed rule would put p=16 off the 256-pixel-tall atlas.

### 5.2 Alpha state used by the producer

For `tsDouble` (shipped), per distinct tag after the base:

```c
if (layer_index == 0) mask = 0;
else if (mask == 0xf) mask = 0;              // 0x8132e5–0x8132ed
p = ALPHA_index(mask, variant);
```

`mask==0` ⇒ patch 0/16 ⇒ both constant-255 ⇒ base/full opacity. The
`mask==0xf → 0` rule prevents a full-cut patch on a plain transition. The
alpha layer UVs are rotated by `rot=2` and V-flipped (`+0xd` byte = TileType
does **not** supply rotation).

### 5.3 Per-vertex quad expansion

- `FUN_00812e34` returns the layer count in `*param_3` (`0x813396`), having
  filled one `0x48`-byte layer record per distinct tag:
  byte `+0` = `art+8` material index, byte `+1` = mirror arg, RGB UVs
  `+5..+0x24`, alpha UVs `+0x25..+0x44` (`ev_6f767eed…`/`ev_e9694d0d…`).
- `FUN_008177f0` installs the producer as callback at `renderer+0x40/+0x44`
  (`ev_9ce28a17…`) and calls `FUN_00818920` (`ev_ec93f0af…`) to build the mesh.
- `FUN_00818428` (`ev_696bc518…`, raw disassembly same id) emits **one vertex**:

```text
0x818454 push [ebp+0x18] ; call 0x4a698c        -> first MultiTexCoord arg
0x81845c fld [ebp+0x14] / fchs ; push           -> second MultiTexCoord arg (negated Y)
0x81846d call glNormal3fv
0x81847f call glColor4fv   (only if [renderer+0x150] != 0)
0x818491 push [ebp-4]/[ebp-8]; push 0x84c0; call [0x8fc39c]  -> texUnit0 UV
0x8184a5 push [ebp-0xc]/[ebp-0x10]; push 0x84c1; call [0x8fc39c] -> texUnit1 UV
0x8184b9 push 1.0f, z, y, x; call glVertex4f
```

`0x84c0 = GL_TEXTURE0`, `0x84c1 = GL_TEXTURE1`. DEC-VIS-01's `0x50`-byte
per-quad expansion stride (`ev_ec93f0af…`) is reused; this pass re-derived the
emission but did **not** independently re-verify that exact stride from bytes —
the 0x48-byte layer stride and 4-vertices-per-layer granularity are proven here.

### 5.4 Exact fixed-function blend / alpha-test state (GL enums from CODE)

From `sub_4ef810` material-state switch on byte `[ebx+0x20]` (RTTI enum:
`bmOpaque=0, bmTransparency=1, bmAdditive=2, bmAlphaTest50=3,
bmAlphaTest100=4, bmModulate=5`; X17/D08, `ev_c6b5ab46…`, `ev_b5ba9e1f…`):

| Case | VA | Operation | GL enum / value |
|---|---|---|---|
| 1 `bmTransparency` | `0x4ef991/0x4ef993/0x4ef995` | `cl=7, dl=6; call 0x88fb78` → `glBlendFunc(table[6],table[7])` | `0x8fb1ac[6]=770=0x302=GL_SRC_ALPHA`; `[7]=771=0x303=GL_ONE_MINUS_SRC_ALPHA` (`ev_ef6544a2…`, `ev_4d202b29…`) |
| 3 `bmAlphaTest50` | same switch | `glAlphaFunc(GL_GEQUAL, 0.5f)` | `table 0x8fb18c[7]=518=0x206=GL_GEQUAL`, ref `0x3f000000` (`ev_da1b30dd…`) |
| 4 `bmAlphaTest100` | same switch | `glAlphaFunc(GL_GEQUAL, 1.0f)` | ref `0x3f800000` (`ev_645fe58e…`) |

Blend equation is the GL default `GL_FUNC_ADD (0x8006)`: `glBlendEquation`
is **not** imported (X17 §5.3; 8 raw CODE string hits with 0 static xrefs,
`U-X17-2`). Exact composite for terrain case 1:

```
src.rgb = shaded tile RGB       (hf.pvl.smx3.frag:13,17,20-30,34-46)
src.a   = texture2D(texUnit1, gl_TexCoord[1].xy).a
dst.rgb' = src.rgb*src.a + dst.rgb*(1-src.a)
dst.a'   = src.a*src.a + dst.a*(1-src.a)      // GL default alpha factors
```

There is **no** mask→RGB multiply in either donor fragment (`hf.pvl.smx3.frag`
full read `ev_11224700…`; SM30 twin identical per X17). `bmTransparency`
enters as fixed-function framebuffer composition, so a port `rgb *= a` is a
**PORT APPROXIMATION**. Note: case 1 at `0x4ef97d/0x4ef987` uses `dl=2`/`edx=0`
helpers before the blend-setter; whether `GL_ALPHA_TEST` is disabled there is
**[U]** (§9 U-6). The number of fixed-function draw passes per cell is
**[U] CONFIRMED_UNVERIFIED** (X17 six passes; D08 §7 #5).

---

## 6. Lighting — exact equation and where the numbers live

### 6.1 Vertex program (`hf.pvl.sm.vert`, full text `ev_83d90ad0…`)

```glsl
realpos = gl_ModelViewMatrix * gl_Vertex;                       // :9
e = normalize(eye - realpos.xyz),  eye = vec3(0.0);             // :4,:12
l = normalize(gl_LightSource[0].position.xyz - realpos.xyz);    // :13
h = normalize(l + e);                                          // :14
n = normalize(gl_NormalMatrix * gl_Normal);                     // :15
ambient  = gl_FrontLightModelProduct.sceneColor
           + gl_FrontLightProduct[0].ambient;                   // :18
diffuse  = max(dot(l,n),0.0) * gl_FrontLightProduct[0].diffuse; // :19
if (vertexColor == 1) diffuse *= gl_Color;                      // :20-21
specular = pow(max(dot(h,n),0.0), gl_FrontMaterial.shininess)
           * gl_FrontLightProduct[0].specular;                  // :23
gl_TexCoord[4] = ambient + diffuse;                             // :41
gl_TexCoord[5] = specular;                                      // :42
```

Fragment (`hf.pvl.smx3.frag`, `ev_11224700…`):

```glsl
color.rgb = texture2D(texUnit0, gl_TexCoord[0].xy).rgb;         // :13
color.a   = texture2D(texUnit1, gl_TexCoord[1].xy).a;           // :14
color.xyz = color.xyz * gl_TexCoord[4].xyz + gl_TexCoord[5].xyz;// :17
// 3-tap PCF shadow :20-30; fog modes 1/2/3 :34-46
gl_FragColor = color;                                           // :50
```

### 6.2 Fixed-function product formation

`gl_FrontLightProduct[0].{ambient,diffuse,specular}` are driver-formed from
`glMaterial* × glLight*`. The engine imports/calls `glLightModelfv` (1 site),
`glLightModeli` (2 sites), `glMaterialfv` (13 sites), `glMateriali` (3 sites),
`glAlphaFunc`, `glTexEnvi`, `glBlendFunc` (`DEC_SMALL_light_products` §3;
`ev_15298ba6…`, `ev_d465405a…`, `ev_921dc17a…`, `ev_3f19390c…`,
`ev_f9fc8845…`). Therefore:

```
ambient_product  = material.ambient(0.15686)  * light.ambient
diffuse_product  = material.diffuse(0.78125)  * light.diffuse
specular_product = material.specular(0)       * light.specular = 0
packed = sceneColor + ambient_product + diffuse_product   // + vertex-colour when enabled
spec_out = 0
```

### 6.3 Numeric values — all in DONOR TEXT, not CODE

| Quantity | Value | File / evidence |
|---|---|---|
| Light ambient (colour) | `(0.196078434586525, 0.184313729405403, 0.129411771893501)` | `light.cfg:3-6`, `ev_ed96da32…` |
| Light diffuse | `(0.811764717102051, 0.780392169952393, 0.694117665290833)` | `light.cfg:9-13`, `ev_ed96da32…` |
| Light specular | `(0.278431385755539, 0.266666680574417, 0.211764708161354)` | `light.cfg:20-23`, `ev_ed96da32…` |
| Sun position / style | `(-0.344731152057648, 0.938701450824738, 0, W=1)`, `lsParallel`, `Shining=true`, no attenuation/spot | `light.cfg:17-38`, `ev_ed96da32…` |
| Material ambient | `0.15686` grey, both faces | `reftile.mat:53-55,81-83`, `ev_fadb2880…` |
| Material diffuse | `0.78125` grey, both faces | `reftile.mat:59-61,87-89`, `ev_fadb2880…` |
| Material specular / shininess | `0` / `16` | `reftile.mat:70-76,98-104`, `ev_fadb2880…` |
| `sceneColor` (`GL_LIGHT_MODEL_AMBIENT`) | **not statically recoverable** — value passed to `glLightModelfv` is stripped in the lifter | `FUN_004d13d4` `ev_3f19390c…`; §9 U-1 |
| Fog colour / start / end / mode | `60,100,150` / `390` / `490` / `0` (OFF); `HFogMode=2`, `HFogStart=200` | `colors.lib:23,34-38`, `ev_d6da102c…` |
| Shadow blend colour | `140,140,140,128` (`0.549020` RGB, α `0.501961`) | `colors.lib:33`, `ev_d6da102c…` |
| Shadow PCF | `of=1/512`, 3 taps (`hf.pvl.smx3.frag`) or 9 taps (`smx9`), `sh/3` or `sh/9` | `ev_11224700…`, `X35` E15 |
| Gamma / exposure | `ImageGamma=1`, `imagebrightness=1` (identity); no gamma/sRGB/tone-map literal in CODE | `reftile.mat` `ev_fadb2880…`; `DEC_SMALL_light_products` §4(4) |

**`sceneColor` is the one genuinely unknown numeric** in the lighting equation.
`glLightModelfv` is called, so the term exists; its float vector is not
statically readable. Do **not** fold it into ambient or invent an exposure
lift (`DEC_SMALL_light_products` §6.3, X35 §5). Exact port replacements for the
other values are already in the current shader uniforms but the specular must
be the **effective product `vec3(0)`**, not the light colour `vec3(0.2784,…)`
(the current `terrain_donor_shader.gdshader:211` was already corrected to
zero; `terrain_donor_mesh.gd:1166` still binds the light colour — the
`material_specular_rgb=0` multiply at shader `:361` cancels it, which is
correct but must be preserved).

---

## 7. Texture units, filters, mip mapping, anisotropy, atlas/block geometry

| Resource | Unit / binding | Filter | Wrap | Geometry | Evidence |
|---|---|---|---|---|---|
| Ground RGB DDS | `texUnit0 → 0` | `maNearest` (mag `GL_NEAREST=0x2600`), `miNearestMipmapLinear` (min `GL_NEAREST_MIPMAP_LINEAR=0x2702`) | `twBoth` (`GL_REPEAT=0x2901` S/T) | one **1024×1024 DXT1** block per tile name, **11 mips**; `grass1.dds` header read directly | `reftile.mat:24-49` `ev_fadb2880…`; `shaders.lib` `ev_80043e7b…`; D08 §3.1 |
| Flat alpha | `texUnit1 → 1` | `maNearest`/`miNearest` (`GL_NEAREST` mag+min) | `twBoth` | `alpha.bmp` **512×256, 8 bpp**, data@1070, 254 palette entries, 8×4 grid of **64²** patches | `reftilealpha.mat:30-37` `ev_c949cdfc…`; `F06-E7/E9/E10` |
| alphavert (face refkeys) | `texUnit1 → 1` (swapped per refkey) | `maNearest`/`miNearest` | `twBoth` | `alphavert.bmp` **1024×512, 24 bpp near-grey**; `TextureScale=(0.125,0.125,0.125)`, `tmmEyeLinear`, front S=X/T=Z, side S=Y/T=Z | `reftile.mat:120-169` `ev_fadb2880…`; `F06-E11/E12` |
| alphanull | `texUnit1 → 1` | same as flat alpha | `twBoth` | `alphanull.bmp` **512×256, all pixel bytes 0**; bound to ids 86/110/123 | `reftilealpha.mat:235` `ev_c949cdfc…`; `F06-E14` |
| `hmapTex` | parameter key **only**, never a terrain texture | — | — | water shader declares it; `heightmapwaves0.tga` alpha all 255 → disproved | D06 §4; shader `:84-92` (current port is correct here) |

Anisotropy: `filteringquality = tfIsotropic` on all three (`ev_fadb2880…`,
`ev_c949cdfc…`) — **no** anisotropic filtering is requested. Native upload
helpers hardcoding `GL_LINEAR` (`sub_5d2ad4`) are **not** proven to be the
terrain DDS path (`DEC_VIS_01` §7.2) and must not override the material text.

Texture units: `shaders.lib` binds `texUnit0 = 0`, `texUnit1 = 1` statically
(`ev_80043e7b…`); `0x818428` uses `push 0x84c0/0x84c1` (`ev_696bc518…`).
`sub_4be364` switches unit `0x84c1 → 0x84c0` around `glTexGenfv` then restores
(D08 §3.6) — the runtime eye-plane values are `[U]`.

Atlas geometry: the donor ships **112 separate 1024² DDS blocks**, resolved by
id → `terrain.presets` name → `tiles.mat` image (`D08` §§1/3.1; `ev_e742a78…`).
The port's 16×8 / 128²-cell packed atlas is explicitly labelled
`APPROX_ATLAS_PACKING` and cannot represent the per-block 8×8 subcell topology
without a layout change (§8.3).

Geometry scale constants from `dmscript.global`: `gc_pixels_to_meter=26.6666666`,
`gc_meters_to_tile=2`, `gc_pixels_to_tile=53.3333333`, `gc_tiles_to_pixels=0.01875`
(D08 §3.6). No donor literal equals the port's `uv_repeat=(0.5,0.5)`.

---

## 8. Exact Godot rewrite plan (no approximations)

All of the following are **spec instructions, not edits made by this worker**.
They replace the current cell-centre `variant3d/scripts/terrain_donor_mesh.gd`
(+ `terrain_donor_shader.gdshader`) behaviour; no change to `app/**`.

### 8.1 Topology change — mandatory

The current mesh has `w*h` **cell-centre** vertices,
`UV2=(float(tile_id), float(face))` (`terrain_donor_mesh.gd:1414–1474`). The
donor producer is **per-cell, per-distinct-tag** (`§3.4`). To reproduce it:

1. For each cell `(x,y)`, build `tags[4]` from `(x+b,y+a)` source vertex ids
   (setter rule §3.2), then apply the `record13+8` object override under the
   `0x830754/0x830818` gate when an override record exists.
2. Dedup + ascending sort → `distinct[1..4]`. Emit **one quad = 4 vertices**
   per distinct tag, in ascending order. Cell count of vertices becomes
   `4 * Σ distinct_count`, not `w*h`. Triangles become
   `2 * Σ distinct_count` per cell (currently `(w-1)*(h-1)*2`).
3. **Vertex positions move from cell centres to donor cell corners.** The four
   corners of a cell are at world `((x+0.5)±0.5)*TILE_M` and
   `((z+0.5)±0.5)*TILE_M` (current centre at `:1434–1436`), i.e. the corners of
   the existing grid cells — this is a genuine topology change, not a UV tweak.
   Normals: use the donor `gl_NormalMatrix` input; the port's 1-cell forward
   difference (`:448–464`) may be kept as the source normal but must be
   evaluated at the **corner** vertices, not cell centres.
4. Do **not** interpolate any selector across a triangle. Bake all four UV
   pairs per vertex on the CPU exactly as §4.3/§5.1 specify; the fragment
   shader contains **no** `mod`/`fract`/id-bit/LUT arithmetic.

### 8.2 Mesh attributes and vertex colour packing

`Mesh.ArrayType` layout (one surface per draw-order group, see §8.5):

| Attribute | Contents |
|---|---|
| `ARRAY_VERTEX` | donor corner position (Y = height field) |
| `ARRAY_NORMAL` | donor-space normal at that corner |
| `ARRAY_TEX_UV` | **RGB uv0** — baked `u0/v0…u3/v3` from `0x812b4c` (§4.3/§4.4) |
| `ARRAY_TEX_UV2` | **alpha uv1** — baked `u0/v0…u3/v3` from `0x812ccc` (§5.1) |
| `ARRAY_COLOR` | `.r` = resolved tile id (0..123) used to select the RGB block layer; `.g` = layer index (0 = base); `.b` = alpha patch index `p`; `.a` = `mask` (or flag bits for scheme/inset/V-flip) |

No extra attribute streams are needed: two UV sets plus RGBA colour carry
everything the donor display list carries in its 0x48-byte record. `UV2.x` is
no longer a face-mode transport — that was a PORT APPROXIMATION
(`terrain_donor_shader.gdshader:24–27`).

### 8.3 Textures and samplers

- Replace `sampler2D tile_atlas` (16×8 packed, `terrain_donor_shader.gdshader:59`)
  with a **`sampler2DArray`** holding one 1024² RGBA layer per used tile id,
  generated from the on-disk `assets/terrain/blocks/*.png` donor-derived blocks.
  This is the only way to reproduce `id → tiles.mat image` without a packed
  atlas approximation (`D08` §5.2). Index = `COLOR.r`.
- Keep `alpha_atlas` as a **512×256** nearest/RGBA texture whose alpha channel
  is the donor index→intensity `max(0, idx-3)` (F06 §3.1) converted by the
  exact `tiaAlphaFromIntensity` rule (§9 U-4) — do **not** invent the formula.
- Keep `alphavert_atlas` as **1024×512**, sampled by the eye-linear projection
  with scale `0.125` and front/side planes (§7); the Z-up→Y-up axis choice stays
  labelled PORT APPROXIMATION until U-8 is resolved.
- Sampler hints: nearest magnify; ground RGB `filter_nearest_mipmap` with a
  full 11-level chain from 1024² (exact donor `GL_NEAREST_MIPMAP_LINEAR`);
  alpha/alphavert `filter_nearest` (no mip). Do not use `textureGrad`/LOD inset
  packing workarounds (`terrain_donor_shader.gdshader:401–439`) — they exist
  only because of the packed atlas.

### 8.4 Shader functions required

| Function | Input | Exact behaviour |
|---|---|---|
| `RGB_index(mask,variant,tileType)` | `COLOR.b/a` + descriptor uniform | Table §3.5; pure byte lookups + range tests. Needed only for the `tsSingle` path; shipped terrain is `tsDouble`, where uv0 is already baked. |
| `ALPHA_index(mask,variant)` | `COLOR.b/a` | §3.5 16-pair table. Bake on CPU; shader need only keep `p`. |
| `blinn_phong(N,L)` | packed varyings | `rgb = texture(tile_array, vec3(uv0, id)).rgb * (sceneColor + 0.15686*La + max(dot(l,n),0)*0.78125*Ld) + 0` (§6). `sceneColor` uniform stays exposed, default must be **cited**, not guessed. |
| `alpha_sample()` | `UV`, `uv1`, face flag | `a = texture(alpha_atlas, uv1).a`; face refkeys swap to `alphavert` with plane projection. **No** `clamp`, `floor`, `step`, `rgb*a`, or id-bit patch decomposition (`terrain_donor_shader.gdshader:450–463` is the forbidden pattern). |
| `blend_out()` | shaded rgb, `a` | `ALBEDO = rgb; ALPHA = a;` with `render_mode blend_mix` for overlay layers; base layer `ALPHA=1`. |

`vertex()` does **no** texgen math: uv0/uv1 arrive as `UV`/`UV2` attributes.
Keep a runtime eye-plane uniform path **only** for the unresolved DEC-U1/U2
question (§9 U-7), explicitly labelled.

### 8.5 Draw order and render state — the remaining hard part

The donor composites layers with fixed-function `bmTransparency` over an
already-drawn base. A single Godot surface with `blend_mix` cannot guarantee
base-before-overlay at equal depth. Implement:

1. **Base pass** — opaque: one surface containing all `layer_index==0` quads,
   `ALPHA=1.0`, depth write on.
2. **Overlay pass(es)** — `render_mode blend_mix, unshaded` (or a dedicated
   `NextPass`/multi-surface draw), containing `layer_index>0` quads sorted by
   cell then layer index, depth test `less_equal`, depth write **off**, alpha
   = raw mask sample. This reproduces `dst.rgb' = src.rgb*src.a + dst.rgb*(1-src.a)`.
3. `cull_disabled` is a port guard against donor `fcCull` (`reftile.mat:18`) —
   keep it labelled, not claimed as donor state.
4. The number of donor fixed-function bmTransparency passes is **[U]**; the
   1-base + up-to-3-overlay structure above is the minimal faithful shape,
   not a claim that the donor issued the same number of GL draws.

### 8.6 What MUST change from the current implementation

| Current file / lines | Why insufficient | Required change |
|---|---|---|
| `terrain_donor_mesh.gd:1412–1474` | `w*h` cell-centre vertices, `(w-1)*(h-1)*2` tris | 4 vertices per distinct tag at cell corners (§8.1) |
| `terrain_donor_mesh.gd:372–400` / `:403–438` | tile map built from one `tex[i]` byte; no tags/variant/rec13 | ingest per-cell `tags[4]+variant+collision[4]+rec13` (§3.1); build setter replay or baked bytes |
| `terrain_donor_mesh.gd:473–495` | face mode from height/collision promotes to 1/2 | donor face art is a **material refkey**, not a promoted cell id; keep `alphavert` path separate |
| `terrain_donor_shader.gdshader:450–463` | id-bit `dir/variant/half/opposite` patch selector | replace with baked `uv1` from `0x812ccc` (§5.1) |
| `terrain_donor_shader.gdshader:389–441` | `fract` + LOD inset + `textureGrad` on packed atlas | bake `uv0` from `0x812b4c`/`0x813235`; use 1024² texture array |
| `terrain_donor_shader.gdshader:330` | `v_alpha_uv = v_st*uv_repeat*alpha_uv_scale` | uv1 is a mesh attribute (`gl_MultiTexCoord1`) |
| `terrain_donor_shader.gdshader:549` | `rgb = rgb*v_packed + v_specular` on one pass | base+overlay layer structure (§8.5); `sceneColor` uniform added |
| light_match/color_unify (`shader:241–271`, `mesh:1122–1173`) | measured candidate-pixel calibration | not donor; may remain only as explicitly labelled PORT CALIBRATION, never folded into the donor equation |

---

## 9. Every remaining [U] with a concrete decomp plan

No item below is "accept approximation". Each has an instrument and a
termination condition.

| ID | Unknown | Concrete decomp / instrumentation plan |
|---|---|---|
| U-1 | Runtime `sceneColor` float passed to `glLightModelfv` | Decompile `FUN_004d13d4` **at instruction level** (`native_function_instructions_list`, then `native_value_flow_show`) from `0x4d13d4` to the `call 0x4afd24` site; identify the source of the pushed float vector (global in DATA vs `colors.lib` palette). Follow xrefs to any `0.palette`→`LSAmbient` loader. Terminate when the four float values and their address are byte-read. |
| U-2 | `glLightModeli` branch enums (`*(param_1+0x123)&8`) | Read `0x4d1409`/`0x4d1417` with `native_instruction_show` + `native_bytes_find` for the immediate pname values; map through GL enum table (`GL_LIGHT_MODEL_TWO_SIDE=0x0B52`, `LOCAL_VIEWER=0x0B51`). Terminate when both immediates are typed. |
| U-3 | Delphi LCG generation-time seed | `native_function_callers_list FUN_004033b8` and `native_xrefs_list DAT_008f2008`; decompile the reseed path from `QueryPerformanceCounter`/`GetTickCount` and record whether the terrain setter stream is shared with other `Random` calls. Terminate with seed source + first draw index (or a documented proof it is runtime-only). |
| U-4 | Exact `tiaAlphaFromIntensity` formula | Find the `tia*` enum in RTTI via `native_strings_find`/`core_feature_find`, then decompile the texture-loader switch that consumes `imagealpha=tiaAlphaFromIntensity` and `textureformat=tfAlpha`. Compare its output to the F06 index→intensity `max(0,idx−3)` table. Terminate with the arithmetic or a byte-exact LUT. |
| U-5 | 13-byte record default template address in loaded DATA | `native_function_disassemble 0x8302b0`/`0x82ed00`; find the OOB-static branch and the address it copies 13 bytes from; `native_bytes_show` that address. Reject `.rsrc` hits (`ev_ff4fffbe…`). Terminate with a DATA/CODE VA + 13 bytes. |
| U-6 | `GL_ALPHA_TEST` enable/disable and exact case-1 helper at `0x4ef97d/0x4ef987` | Full 224-insn disassembly of `sub_4ef810` already in X17; step the two helper calls with `native_instruction_show`, resolve their imports (`glEnable`/`glDisable`/`glAlphaFunc` thunks), and identify the pname values pushed. Terminate when the terrain case-1 enable mask is enumerated. |
| U-7 | Effective `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` at ground draw (DEC-U1/U2, D08 §7 #6) | `native_function_study 0x4be364` (takes caller-supplied plane pointers) + `native_call_graph_show` back to the HeightField draw caller; decompile the caller and identify the pointer source. Cross-check the default planes at `0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4` and matrix at `0x8f4b44` (`ev_1a116a59…`). Terminate with VA + 4 floats per plane. |
| U-8 | Z-up→Y-up axis remap for `alphavert` face planes and normals | The donor planes are in `reftile.mat:120-169` (`ev_fadb2880…`); find the engine's modelview/material transform applied before `glTexGenfv` via `native_name_xrefs_list glTexGenfv` and `FUN_004ec3f0` (`ev_97d7b661…`). Terminate with the transform matrix applied to S/T. |
| U-9 | Exact number of fixed-function `bmTransparency` draw passes per cell | X17 exhausted six passes on `sub_7829a4`/`sub_53dae0`; next instrument is `native_call_graph_show` from `sub_4ef810` **forward** to the draw-dispatch and `native_value_flow_show` on the pass-count variable. If static analysis stays ambiguous, this is the one item that needs an authorised GL trace — **not** a permission to assert "one pass" or "two passes". |
| U-10 | Per-cell topology: exact `0x48→0x50` quad expansion stride | `native_function_instructions_list 0x818920` already shows 0x30-stride scratch rows; walk the loop that reads the 0x48 layer records and writes the per-vertex struct, recording the destination stride and field order. Terminate with a field-by-field 0x48→vertex map. |
| U-11 | Setter callers beyond DScript `0x6b1d50` | Built-in xrefs report 0 for undiscovered high VAs; run `native_rizin_command_run` with `axt @ 0x8326b8` on the raw file (Rizin may index the bytes Ghidra missed), then `native_bytes_find` for the `E8`-relative call encoding to `0x8326b8`. Terminate with a caller list or a documented negative. |
| U-12 | `record13 +4..+7` flag names and `+10/+11` controls | `native_function_callers_list 0x80ec30` / `0x830d8c` / `0x830c68` and `native_value_flow_show` on each; classify by which corner is cleared/thresholded. Terminate with authoritative enum names from the RTTI name table if present. |
| U-13 | Visual parity | Requires a donor GPU A/B frame. **No** port worker may claim it. This is the only `[U]` that cannot be closed by static decomp under the read-only charter; it stays open, not waived. |

---

## 10. Delta beyond the starting reports

| Prior claim | This pass | Status |
|---|---|---|
| DEC-VIS-01 §5.4 patch mapping `col=p%4` | raw call + F06 patch means show `col=p/4`, `row=p%4` | **Superseded** (§5.1) |
| DEC-VIS-01 §5.4 "parity +16 ⇒ v+1 ⇒ repeat-equivalent under twBoth" | `p+16 ⇒ u+0.5`; patches (0,1)/(4,1) differ (45.6 vs 82.8) | **Withdrawn** (§5.1) |
| DEC_DEEP / DEC_VIS-04 record13 default `@0x8fab6c` | bytes there are pointer-like; `00*10 ff ff 00` only in `.rsrc` | **Changed to [U]** (§3.1, U-5) |
| DEC_VIS-01 §3.5 corner compare order 8/4/2/1 | raw pairs slot0→8, slot1→2, slot2→4, slot3→1 | **Refined** (§3.4) |
| DEC_VIS-01 §6.1 full-variant table described as one `[0,15,16,17,18,19]` array | five byte ranges + implicit 0, with exact `param_3==1` gating | **Completed** (§3.5) |
| DEC_VIS-01 §4.2 tsDouble "Rows, as written" for both axes | confirmed: both axes divide by `[art+0x24]`, `+0x25` is used only in the tsSingle/RGB-LUT path | **Confirmed** (§4.3) |
| X35 / DEC_SMALL "specular contradiction" | current shader `specular_rgb=0` resolves it; `material_specular_rgb=0` multiply cancels the mesh's light-colour binding | **Confirmed with wiring note** (§6.3) |
| X17 pass count `[U]` | unchanged, U-9 plan added | **Still [U]** |

---

## 11. Bottom line

The donor terrain renderer is fully specified at byte level: **four corner
tags + one variant byte per 24-byte cell**, sorted distinct tags, a `8/2/4/1`
occupancy mask, two fixed byte LUT families (`0x8f5cd7…` and `0x8f5d00`),
**explicit per-layer RGB and alpha UVs** written by `0x812b4c`/`0x812ccc`
with rotation/mirror/V-flip immediates at `0x813210/0x8132ac/0x81336a`, four
vertices per layer emitted by `0x818428` to texture units `0x84c0/0x84c1`,
and a fixed-function `bmTransparency` framebuffer crossfade using
`GL_SRC_ALPHA`/`GL_ONE_MINUS_SRC_ALPHA`. Lighting is the two-term
`sceneColor + material×light` ambient plus diffuse Blinn–Phong with **zero
effective specular**; all numbers except `sceneColor` live in donor text
(`light.cfg`, `reftile.mat`, `reftilealpha.mat`, `colors.lib`, `shaders.lib`).

A faithful Godot rewrite therefore needs a **topology change from cell-centre
to donor-corner vertices**, a texture array of 1024² blocks, baked uv0/uv1
attributes, and a base+overlay draw structure — not a shader-only patch. The
remaining unknowns are runtime GL bindings and pass counts; each has a
concrete decomp plan in §9. **No donor visual parity is claimed.**

*End of PORT1TO1-RENDER. Files written: this report only. Donor read-only; no
binary executed/copied; no code, shader, config, asset, test, git or Godot state
changed.*
