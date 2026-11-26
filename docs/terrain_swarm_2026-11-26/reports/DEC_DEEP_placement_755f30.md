# DEC_DEEP_placement_755f30 — donor object-placement path in `sub_755f30`

Target: pinned Craft Anything document `t_87f0f3c130b0` (`cossacks.exe`,
sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`).
Cross-check: `t_68474ddde43f` (`editor.exe`) `sub_8c5b78`.
Method: Deep/native dossier + clean-room pseudocode + raw assembly pages +
callee decompiles + caller graph + `native_data_show` constants + string search.
Donor READ-ONLY; no execution, no binary copy. No parity claim.

Prior DEC-VIS-02 findings reused only where explicitly cited as carried
evidence; everything else below was re-observed in this pass.
Notation: [O]=observed donor bytes/text, [D]=derived inference, [U]=unknown.

---

## 1. What `sub_755f30` is [O]

- `sub_755f30` at VA `0x755f30`: 234 basic blocks, 6751 instructions,
  662 internal calls, 5 callers, 0 strings, 0 jump tables.
  Evidence `ev_ed57855c0a723d2bf9995595ceb89e76ef66946ef0ebee56bd6c690a21035a36`.
- Callers (`ev_0ce569d617b3f2ca8e6abbd35e8c2702c8d2e3c4b9bb23deb0122c71a4b`):
  `sub_6b2b58` site `0x6b2bfc`, `sub_723748` sites `0x723bf9`/`0x723cbc`,
  `sub_75c228` site `0x75c240`, `sub_75c1fc` site `0x75c28e`.
- `sub_75c228` is a thin wrapper [O] (`ev_370b6b9ca320560721f1332f9fb5f48c53972c31ca91714b90cefd1b584e6210`):
  `sub_75c228(): sub_755f30(0x42b40000, 0, arg_8, arg_c, arg_10)`.
  `0x42b40000` = f32 90.0 (angle base, see §5).
- `sub_723748` (generator Stand driver) branches on pattern `+0x41` [O] (same evidence):
  `+0x41==0` → `sub_75c228(...)`; `+0x41!=0` →
  `sub_755f30(*(esi+0x38), *(esi+0x34), ...)`. This is the
  `StandPattern` vs `StandPatternWithAngle` fork. Exact DScript names are NOT
  in the binary (`ev_afce8c7bcf9c2460dde35fdc105f54edddc9cd`: 0 hits for
  `StandPattern`; `ev_e61ad50edcf1182772d58ffe69049161b001e3df2e24c7242ca1de9a725230f9`:
  0 hits for `ObjectsScale`; only `uXGameObjectsGrid` in `.rsrc`,
  `ev_22f807f72b01605f0e6bf0f475b9043726e8c6f1ba2d6a6aa89b5af086a78d1`).
  So the fork semantics are structural [D]; the DScript names are carried [O]
  from script-side reports (fnd_2/fnd_3), not proven in CODE here [U].
- Entry prologue [O] (`ev_06dcc95039110c72cfead68b6b45660414ea29f461a4c3a7f0df66e6ebaea9b0`,
  VA `0x755f30`–`0x755faf`): four lazy-init gates on the pattern object
  (`eax=[ebp-4]`):
  `+0x89==0→sub_75ca34`, `+0x8a==0→sub_75cf6c`,
  `+0x8b==0→sub_75cfb8`, `+0x8c==0→sub_75d004`.
  Then rotation setup at `0x755fb4` (`fld tbyte [0x75c198]`,
  `fdivr [ebp+0x10]`) and centre selection at `0x755fec` (`jae 0x75603a`).

## 2. Stamp frame: rotate / centre order [O+D]

Re-observed in `ev_139fa697968693dfa5d3151505592a7d4a90c1ea` (offset 0) and
`ev_745cce620ea0f146fff871cc3f5deb8ae735cafd463302816c7854ff0e0b8ecf`
(editor mirror):

1. Load `rotangle = [ebp+0x10]` (float degrees).
2. Compute `f = round(patternW_longdouble?)` style quantity via
   `fild [ebp-0x148]` / `fld tbyte [0x75c198]` / `fmulp` / `fsubr rotangle` /
   `fabs`, compare against global f32 at `[0x8fc428]`.
3. `jae 0x75603a` taken (normal case): stamp centre is
   `C = ([ebp+0x18]+[eax+0x74], [ebp+0x14]+[eax+0x78])`
   stored to `[ebp-0x30]/[ebp-0x34]` (`0x75603a`–`0x756054`).
   Else (mirrored/rotated case): build a 2D rotation via `sub_4a2170` +
   `sub_4a3b9c` on `[ebp-0x144]` and add to the same inputs.
4. Half-extents: `(W-1)>>1`, `(H-1)>>1` with arithmetic-shift negative
   correction (`arg_ffffffb4`/`arg_ffffffb0`). [O] pseudocode lines at top of
   `ev_139fa...`.
5. Integer stamp bounds `esi=floor(...)` via `sub_4a6aa0`,
   `edi=floor(...)`, then `endX/endY` (`arg_ffffffe8`/`arg_ffffffe4`).
   Float→int is `sub_4a6a5c`, float-floor/round is `sub_4a6aa0` throughout
   (662 callees, `ev_4a342bbec75c9302fc7e3ec7d35583c16e`); neither is an RNG
   source [D]. No `RandomExt`/Delphi-`Random` import appears in the callee list
   [O].
6. Rotation helpers for every cell: `sub_403404` (=cos) and `sub_40342c`
   (=sin) of `rotangle`, then the per-cell
   `x' = (ix-…)*cos + (iy-…)*sin`-style reconstruction visible as repeated
   `fild/fdiv [0x75c1a4]/fmulp/faddp/fsubrp` sequences. Divisor is f32 2.0
   (`ev_f391923800456236a50dcfbdbaa94b46e798c488c1c75610c4adb57440510a95`
   at `0x75c1a4`, 252 references) and `+0.5` at `0x75c1a8`
   (`ev_a913e352db1b7061b028888de0a42f5bd9758672850de984c0625ee2480c6525`).
   So order is: **rotate cell offset → scale/divide → add stamp centre** [D].

Editor `sub_8c5b78` repeats the identical prologue with relocated long-double
table (`0x8cbde0` vs `0x75c198`, `0x8cbdec` vs `0x75c1a4`,
`0x8cbdf0` vs `0x75c1a8`) [O] (`ev_745cce...`). Prior DEC-VIS-02 normalized
diff of the 542-instruction object block reported zero mnemonic/operand
differences; carried as [D] (fnd_46:
`ev_c176cc8193528500e5f914c7bf4ecccf5424bbe81125f92a78de2a3237`,
`ev_8134dae4e0fb4794b43bdb0044dd7c59dd18fa806e18ffa8fe285aa04`,
`ev_c041ddb4f6ae4f802e6c8af0a5bbdfab5816ac6a0f1358a57840ccdb987a2c4b8`,
`ev_6ebd3fd5bc50d1ed089f11c34f0771c5f8c6c107513cb5e09cf8e2bd68d`,
`ev_98156ac68a90653b7f9d09a39fd358ff2d545733d323de5475442be42ee11e`).
This pass confirms structural identity on the sampled pages [O]; a full
byte-for-byte re-diff was not run [U].

## 3. Object-record fields and placement order [O+D]

Three record streams are indexed by `(rowBase=[pattern+off], col)` inside
`sub_755f30`. Sizes are proven by the copy idioms [O]:

- `+[0x2c]` stream: `rep movsd ecx=6` → **24 bytes/record**
  (label `756731` region, `ev_139fa...` tail / `ev_db687a2c2912fed32867a0530b52f288c8f90bf7c634cb0538a02348` head).
  Pseudocode: `edx=*(pattern+0x2c); eax=*(edx+row*4); edx=col-esi;
  edx=edx+edx*2; esi=eax+edx*8; rep movsd [edi],[esi] (ecx=6)`.
  `edx+edx*2` (=`3*edx`) then `*8` = `*24` stride. [O]
- `+[0x30]` stream: 4× `movsd [edi],[esi]` → **16 bytes/record**
  (labels `7569c0`/`757564` region, `ev_db687a...`).
- `+[0x34]` stream: 3× `movsd` + `movsb` → **13 bytes/record**
  (label `756cb1` region, `ev_db687a...`):
  `edx*=13; esi=eax+edx; movsd/movsd/movsd/movsb`.
  This 13 B layout matches the DEC-VIS-04 tail record
  (values 0..3 / flags 4..7 / override 8 / override_rnd 9 / control 10..11 /
  dirty 12) [D, carried].

Per-instance pipeline for the `+0x18`-gated (24 B) stream [O+D]:

1. Gate `if (*(pattern+0x18)!=0)` at label `7566ff` (`ev_db687a...` shows
   `label_7566ff:` then the `+0x18` test). Only then enter the double loop
   over `(ecx=rowLocal, ebx=colLocal)`.
2. Recompute rotated coords (same cos/sin/`/2.0` idiom as §2).
3. Fetch one 24 B record (`+0x2c`, stride 24, `rep movsd ecx=6`).
4. Stand-mask test: `eax=*(rowBasePtrs[rowLocal]); if (*(eax+colLocal)==0)` then
   transform + place, else skip. Exact fragment [O]:
   `eax-=edi; edx=rowBase; eax=*(edx+eax*4); edx=ebx; edx-=esi;
   if (*(eax+edx)==0) { ecx=&stack24; edx=&rec24; sub_755bc8(arg_10); ... sub_755664(1, ...) }`.
5. `sub_755bc8` (24 B pre-transform, `ev_8f8556fb7dfe13f1eb29e2c30b04c1fa23fd4d49c496032efe1524e6b0b3c6`):
   copies 24 B, then `fcomp [0x755c58]` (f32 **0.0**, `ev_ed80ef41a4d2e475be4155975c596aca7df73c02307095b8ee65e3e7665bd663`)
   and if below, `fadd tbyte [0x755c5c]` (10-byte extended constant,
   raw `21 68 C2 35…`, `ev_db56bc2f434a17793aeb04f63e30e56417ff09922ca3b529ca057049c5ed3fc8`);
   then `fdiv [0x755c68]` (f32 **90.0**, `ev_1b2e925ce94b87e0f955848a35f4c5e3a79b7de1408ddd6d0548ee8f6091455c`),
   `sub_4a6520` + `sub_4a6a5c` loop that permutes 4 corner bytes
   (`*(ebx)=*(esi+1)`, `*(ebx+2)=*(esi)` …). [O] This is angle
   normalization/rotation-bake for the 24 B record [D].
6. `sub_755664` (placement, same evidence): re-derives half-extents
   (`[edx+8]>>1`, `[edx+4]>>1`), reads `arg_8` count and `*(+0x118)` scale
   factor, performs the 8-way rotated-quadrant dispatch into
   `sub_59b8a4` variants (`+0xa8/+0xac/+0xb0/+0xb4/+0xb8/+0xbc/+0xc0/+0xc4`)
   or `sub_82ecac`, then if `+0x83!=0 && arg_8!=0` runs four
   `sub_755578` fixups (one per corner byte). The quadrant tests are
   `-halfW<=pos<+halfW` style integer comparisons. [O+D]
7. `sub_755920` (second placement helper, same evidence) is the same
   8-way dispatch but into `sub_59b854` (+ identical `+0xa8…+0xc4` table)
   plus the trailing 4-byte rotation (`*(edi)<->*(edi+1..3)`).
   Used by the `+0x82`-gated 16 B stream (`sub_755bc8`→`sub_755664` vs
   `sub_755bc8`→`sub_755920` pairs repeat through `0x757500`–`0x75b3ff`,
   `ev_4a342...`). [O]
8. `sub_755d1c` (16 B pre-transform, `ev_8f8556...`): 16 B copy
   (4×`movsd` twice), `fcomp [0x755da0]` (**0.0**, `ev_b233358a...`),
   `fadd tbyte [0x755da4]`, `fdiv [0x755db0]` (**90.0**, `ev_dc6a24...`),
   then 4-dword permute loop. [O] `sub_755c6c` is the 13 B analogue
   (3×`movsd`+`movsb` twice, `fcomp [0x755d08]` **0.0**,
   `fdiv [0x755d18]` **90.0**). [O]

Field order inside the 24 B object record is NOT fully typed by the lifter
(register-level, `ev_ed57855...` limitations) [U]. Carried DEC-VIS-02 decode
(fnd_44, [D]) that this pass is consistent with but does not independently
re-type:

> `Position.xz` rotated by `PI−rotangle`, multiplied by `ObjectsScale`,
> added to raw stamp centre or width/height-rounded half-cell centre;
> record `Y` used only with `ObjectsHeightOffset`; terrain sampling only
> under `ObjAutoOffset`; `Direction`, `Up`, `Scaling*ObjectsScale` applied
> before final `sub_7cca74` turn.

What this pass adds [O]: the 24 B copy precedes the 90.0-divide + corner-byte
permute (`sub_755bc8`), and the 8-way `sub_59b8a4`/`sub_59b854` dispatch with
`+0x83`-gated `sub_755578` corner fixups is the concrete “final turn”
region. `sub_7cca74` itself is only `sub_4cb27c(arg_8)`
(`ev_77008d01e5418fff8c23dbfbe8d6c0234c8ea82466fce416ad48ca26017c4af0`) —
  a renderer/actor submit trampoline, not geometry math [D].
  Its exact contract (which register carries Direction/Up/Scaling) is [U].

## 4. `GameObjectsStand` acceptance [O+D, with carried [D] for angle fields]

- Stand-mask + bounds helpers re-observed [O] (`ev_8f8556...`):
  - `sub_755168`: `ebx=*(pattern+4); esi=*(ebx+8); edi=(esi+0xa4)>>1;
    edx+=edi; eax=(esi+0xa0)>>1; ecx+=eax; sub_764e04()`.
  - `sub_764e04` (`ev_77008d...`): `if (0<=edx<*(eax+0xa4) && 0<=ecx<*(eax+0xa0))
    *( *(eax+0xa8)+edx*4 + ecx ) = arg_8`. So `+0xa0`=W, `+0xa4`=H,
    `+0xa8`=row-pointer table. [O] This is the mask-stamp primitive [D].
  - `sub_7550f8` (pure test): half-extent computation from
    `[esi+8]`/`[esi+4]` (`ebx=-W; ebx>>=1` …) then four
    `-half<pos<+half` checks; returns `ebp` sentinel on miss. [O]
  - `sub_75505c` (test+stamp): same four bounds checks, then
    `edx+=halfW; edi=halfH; edi+=ecx; if (*(esi+0x65)!=0) sub_7d9694(...);
    eax=*(rowTable[edx]); eax=*(eax+edi*4); *(eax+0x1c)=arg_8`. [O]
    `+0x65` is a per-pattern “auto/collide” flag [D]; `+0x1c` is the per-cell
    occupant/object id slot [D].
  - `sub_755010`: half-extents + `sub_82ed4c` (terrain-object link) [O].
- Map-bounds rule [D from O]: every helper requires
  `-halfW < dx < +halfW` AND `-halfH < dy < +halfH` after centre
  adjustment; out-of-range cells are silently skipped (no wrap, no clamp).
  `sub_764e04` additionally requires `0<=x<W, 0<=y<H`. [O]
- Stand-mask rule [O]: `al = *(pattern+0x80) & maskByte; if (al!=0)
  sub_755168(...)` (label `75638e` region, `ev_139fa...`). So `+0x80` is the
  required-stand bitmask ANDed with the per-cell mask byte from the
  `+0x24` stream before any height/object work. [D]
- minangle/maxangle [D carried, NOT re-typed here]: DEC-VIS-02 fnd_46 states
  the object loop visits every record with no RNG; `minangle<=0` and
  `maxangle>=90` bypass per-object bounds/angle filtering, otherwise both
  donor normal-angle metrics must lie strictly between min/max. The 90.0
  divisors above (`0x755c68`/`0x755db0`/`0x755d18`) are consistent with a
  degree→quadrant normalization, and the `fcomp 0.0` + extended-constant add
  is consistent with wrapping negative angles, but the exact
  `minangle`/`maxangle` field offsets inside the 24 B/16 B records were not
  re-isolated in this 6751-insn pass [U]. Do NOT treat the 90.0 as the
  min/max themselves; they are normalization constants [D].
- Collision/stand streams: `+0x38`-gated 13 B stream calls
  `sub_755c6c` + `sub_755010` (`ev_db687a...` label `756c9f`); the
  `+0x39`/`+0x4c` gates select height-scale vs offset-scale
  (`fmul [ebp-0x20]` with or without `fsub/fadd [eax+0x5c]`) [O].
  Full tag semantics (which 13 B byte is “stand” vs “collision”) remain [U].

## 5. Constants pinned in CODE [O]

| VA | Value | Use |
|---|---|---|
| `0x755c58` | f32 0.0 (`ev_ed80ef…`) | 24 B angle `fcomp` floor |
| `0x755c68` | f32 90.0 (`ev_1b2e92…`) | 24 B `fdiv` (deg→quad) |
| `0x755da0` | f32 0.0 (`ev_b23335…`) | 16 B `fcomp` floor |
| `0x755db0` | f32 90.0 (`ev_dc6a24…`) | 16 B `fdiv` |
| `0x755d08` | f32 0.0 (`ev_900f9d…`) | 13 B `fcomp` floor |
| `0x755d18` | f32 90.0 (`ev_09c56e…`) | 13 B `fdiv` |
| `0x75c1a4` | f32 2.0 (`ev_f39192…`, 252 xrefs) | half-size divide |
| `0x75c1a8` | f32 0.5 (`ev_a913e3…`) | half-cell rounding |
| `0x755ee4` | f32 4.0 (`ev_ae9a80…`) | 4-neighbour average divisor in `sub_755db4` smooth |
| `0x723e34` | f32 75.0 (`ev_cbd8ef…`) | generator outer-loop scale (`sub_723748`) |
| `0x723e44` | f32 2.0 (`ev_ad9207…`) | generator divide |
| `0x75c198`/`0x755c5c`/`0x75c1ac`/`0x755da4`/`0x755d0c`/`0x723e38` | 10-byte `tbyte` (raw `21 68 C2 35…`, e.g. `ev_db56bc…`) | x87 extended constants (PI-family); exact real values NOT decoded — do not hard-code as PI in port [U] |
| `0x75c1b8` | raw `CD CC CC CC…` (`ev_6d67e8…`) | [U] — appears in `sub_755db4` distance path; not typed |

`sub_75c228` passes `0x42b40000` (=90.0f) as the angle base [O]
(`ev_370b6b...`).

## 6. Pattern `Objects[]` → prop meshes/materials [D, partial]

- The 8-way dispatch is the material key [D, O structure]:
  `sub_755664`→`sub_59b8a4` and `sub_755920`→`sub_59b854` select one of eight
  callee slots (`+0xa8…+0xc4`, stride 4) based on rotated quadrant +
  half-extent comparisons. Only the fallthrough corner calls `sub_82ecac` /
  `sub_82ee04` / `sub_82edcc` (terrain-object link) instead of a material
  submit. The per-corner `sub_755578` fixup (gated by `+0x83`) resolves the
  mesh/material id through `+0x18`-linked actor tables
  (`sub_576dfc`/`sub_82e2f4`/`sub_5df5e4`/`sub_5df3a8` chain,
  `ev_77008d...`) [O structure, D naming].
- Concrete mesh filenames (`.osm`), material names, and the
  `Objects[i]` index→mesh table are NOT in CODE strings (0 hits, §1) [O].
  They live in donor script/pattern data (`pattern.lib`, `misc.script`
  `_misc_CheckStandPattern` family per fnd_3) and engine actor tables
  reached indirectly via `sub_7d9694`/`sub_84a7d8` [D]. Do not invent an
  index→mesh mapping [U].
- Port implication: treat the 24 B record’s mesh key as opaque until the
  pattern-data decode (F-pattern worker) supplies it; the CODE side only
  proves (a) 8-quadrant selection, (b) per-corner fixup, (c) final submit
  via `sub_7cca74→sub_4cb27c`.

## 7. LOD / selection ranges and per-instance efficiency [D carried + O]

- Carried DEC-VIS-02 fnd_46 [D]: Actor LOD has one mesh range 0..150 and a
  separate shader/distance range 0..2500. This pass did not re-isolate the
  LOD struct (no LOD strings in binary, no LOD fields typed in the lifter)
  [U]. Do not port as verified; re-verify from actor tables before use.
- Selection/visibility is mask-driven, not frustum-driven here [D from O]:
  per-cell `standMask & +0x80` test + half-extent bounds test gate every
  submit; there is no per-record distance cull inside `sub_755f30`
  (distance culls, if any, live in the renderer behind `sub_4cb27c`) [D].
- Efficiency [D from O callee fan-out]: no batching/instancing in this path.
  Per surviving cell the donor pays: one 24 B (or 16 B / 13 B) stack copy,
  one `sub_755bc8`/`755d1c`/`755c6c` normalize, one `sub_755664`/`755920`/
  `sub_755010` dispatch, plus up to four `sub_59b8a4`/`59b854` submits and
  four `sub_755578` fixups. The outer loops are dense
  (`rowLocal × colLocal × records`) with no early-out except the mask/bounds
  tests. A Godot port must NOT mirror this per-corner submit pattern
  (see §9); use one MultiMesh per prop mesh instead [D recommendation].

## 8. Per-record RNG / deterministic variation [O+D]

- The `sub_755f30` callee set (662 entries, `ev_4a342...`) contains only
  float/int conversions (`sub_4a6a5c`, `sub_4a6aa0`, `sub_4a6520`),
  trig (`sub_403404`, `sub_40342c`, `sub_403a28`), and stamp/submit helpers.
  No `RandomExt` LCG (`0x60f64c`), no Delphi `Random(256)` (`0x8f2008`
  stream), no `QueryPerformanceCounter`/`GetTickCount` seed call appears
  in the dossier [O]. The object double-loops visit every record in order
  with no draw counter [O] (labels `756731`/`7569c0`/`756cb1`/`756ef0`/…).
- Therefore per-instance variation in this path is **authored, not rolled**:
  any yaw/scale jitter must come from the 24 B/16 B record bytes themselves
  (via the `sub_755bc8` permute + `sub_755578` fixups), not from an RNG call
  here [D]. If the pattern data has no jitter fields, the donor places
  identical transforms [D].
- [U]: whether StandPatternWithAngle adds a deterministic angle derived
  from `(esi+0x34)/(esi+0x38)` (the two extra args at the `+0x41` fork) vs a
  stored per-record angle. The two dwords are passed through to `sub_755f30`
  but their use as `minangle/maxangle` vs base yaw was not isolated [U].

## 9. Concrete port recommendations (`terrain_donor_props.gd` / `terrain_donor_gen.gd`)

Do NOT claim parity. Implement only what is proven above:

1. `terrain_donor_gen.gd` — stamp frame (proven):
   - `rotangle_deg: float` input; centre `C = origin + patternOffset74/78`
     in the normal branch; half-extents `(W-1)>>1`, `(H-1)>>1` (arithmetic
     shift, negative correction); bounds via `-halfW<dx<+halfW`,
     `-halfH<dy<+halfH` + `0<=x<W, 0<=y<H` for mask writes.
   - Per-cell rotated coords with `cos/sin(rotangle)`, divide by `2.0`
     (`0x75c1a4`), add `0.5` (`0x75c1a8`) for half-cell rounding.
     Constants `0.0/90.0/2.0/0.5/4.0` above are the ONLY CODE constants to
     port; NEVER hard-code the `tbyte` extended values as PI — leave them
     `[U]` with a TODO referencing this report.
2. `terrain_donor_gen.gd` — gates (proven structure, opaque ids):
   - `if pattern.rot_init89==0: _init_a()` … through `0x8c` (names TBD).
   - `if (standByte & pattern.accept80)!=0` before height/objects.
   - `if pattern.hasObjects18: place_stream(0x2c, 24)`; `if hasX82:
     place_stream(0x30, 16)`; `if hasX38: place_stream(0x34, 13)`.
   - Keep the three streams SEPARATE functions; do not merge 24/16/13 B
     records into one struct (they have different pre-transforms:
     `obj24_pre`=`sub_755bc8`, `obj16_pre`=`sub_755d1c`,
     `tag13_pre`=`sub_755c6c`).
3. `terrain_donor_props.gd` — per-instance transform (order proven, fields opaque):
   - `xform = translate(C) * rotate_y(PI - rotangle) * scale(objectsScale)
     * translate(record.xz)`, then `y = record.y if heightOffset else
     terrain_sample(x,z) if autoOffset else C.y`-equivalent.
     Apply `direction/up/scaling*objectsScale` BEFORE the final yaw submit
     (renderer call, donor `sub_7cca74→sub_4cb27c`; port as
     `add_instance(mesh, xform)`).
   - Normalize record angle EXACTLY as donor: `if a<0.0: a+=TBX; a/=90.0`
     with `TBX` left as a named constant `DONOR_TBYTE_UNVERIFIED`
     (do not guess PI); corner-byte permute per `sub_755bc8` pseudocode.
   - `minangle/maxangle` filter: implement as
     `if minangle<=0.0 and maxangle>=90.0: accept else: angle_test()` with
     `angle_test()` stubbed to accept-all + `push_warning("angle gate unverified")`
     until the F-pattern worker types the angle fields. This matches carried
     fnd_46 without asserting field offsets.
4. `terrain_donor_props.gd` — keying/LOD/efficiency (do not mirror donor submits):
   - Mesh key = opaque `record.mesh_key`; resolve via pattern-data lookup
     (F-worker), NOT via the `+0xa8…+0xc4` engine vtable indices.
     The 8-way quadrant dispatch becomes a comment, not code.
   - One `MultiMeshInstance3D` per prop mesh; set `instance_count` once.
     Donor per-corner `sub_59b8a4/59b854` submits are a DONT-PORT
     performance trap.
   - LOD `0..150` / `2500` are CARRIED [D], not re-verified: expose as
     `const LOD_MESH_MAX := 150.0  # UNVERIFIED (DEC-VIS-02 fnd_46)` and
     `const LOD_FADE_MAX := 2500.0 # UNVERIFIED`, wire to
     `visibility_range` only, never to placement.
5. RNG discipline: NO RNG calls in the placement loop. If variation is
   needed, source it from record bytes or a separate documented pass with
   its own seed; never insert `RandomExt`/Delphi-`Random` draws here or
   replay order breaks (cf. D02 stage-key discipline, fnd_19–21).

## 10. Strange results / non-silenced items

- The lifter emits 45 unstructured `goto`s and 2802 `__asm` insns for
  `sub_755f30` (`ev_ed57855...` limitations); the 8-way quadrant pseudocode
  in `sub_755664`/`sub_755920` has inverted-then-corrected branch nesting
  (labels `7556d5`/`755b68`). Treated as control-flow noise, not semantics;
  the quadrant TABLE (`+0xa8…+0xc4`) and bounds comparisons are stable
  across all four decompiles [D].
- `sub_75c1fc` decompiles with `popa/popad/arpl/insd/outsd/bound` garbage
  (`ev_370b6b...`) — a lifter mis-decode of jump-table/data bytes, not real
  placement logic. Ignored for this task; only its `sub_755f30(...)` call
  site is cited [D].
- Two `movsd [edi],[esi]` repetitions in the 16 B path copy 16 B total, not
  32 B; the second copy is stack→destination (verified by `esi/edi` swap in
  `ev_8f8556...`). Noted to prevent a double-size port bug [D].
- Full-corpus mask census (fnd_33) and tile-anchor correction (fnd_58) are
  out of scope but constrain this path: only `B`+white-starts vary in
  shipped masks, so any `R/G`-keyed prop scatter in the port is script-schema,
  not shipped-mask data [D].

## 11. Evidence index (this job)

- `ev_ed57855c0a723d2bf9995595ceb89e76ef66946ef0ebee56bd6c690a21035a36` —
  `sub_755f30` dossier (234 blocks / 6751 insn / 662 callees / 5 callers).
- `ev_0ce569d617b3f2ca8e6abbd35e8c2702c8d2e3c4b9bb23deb0122c71a4b` — callers.
- `ev_139fa697968693dfa5d3151505592a7d4a90c1ea` — pseudocode pp.0–32k
  (prologue, centre, half-extents, stand test, `+0x80` gate).
- `ev_db687a2c2912fed32867a0530b52f288c8f90bf7c634cb0538a02348` — pseudocode
  pp.32–64k (24 B `rep movsd`, 16 B / 13 B streams, `+0x18/+0x82/+0x38` gates).
- `ev_4a342bbec75c9302fc7e3ec7d35583c16e` — full 662-callee list
  (no RNG; `755bc8/755664/755d1c/755010/75505c/7550f8/755920/755c6c/755db4`).
- `ev_8f8556fb7dfe13f1eb29e2c30b04c1fa23fd4d49c496032efe1524e6b0b3c6` —
  decompiles of the 10 placement helpers (24/16/13 B pre-transforms,
  bounds test/stamp, 8-way dispatch).
- `ev_77008d01e5418fff8c23dbfbe8d6c0234c8ea82466fce416ad48ca26017c4af0` —
  `755578/7cca74/7553a0/7551a8/764e04/7d9694` (fixup chain, submit
  trampoline, mask write, occupant link).
- `ev_370b6b9ca320560721f1332f9fb5f48c53972c31ca91714b90cefd1b584e6210` —
  caller decompiles (`75c228` wrapper with 90.0; `723748` `+0x41` fork).
- `ev_745cce620ea0f146fff871cc3f5deb8ae735cafd463302816c7854ff0e0b8ecf` —
  editor `sub_8c5b78` mirror (relocated tables only).
- Constants: `ev_ed80ef…` (0.0), `ev_1b2e92…` (90.0), `ev_09c56e…` (90),
  `ev_dc6a24…` (90), `ev_f39192…` (2.0), `ev_a913e3…` (0.5),
  `ev_ae9a80…` (4.0), `ev_cbd8ef…` (75), `ev_ad9207…` (2),
  `ev_db56bc…`/`ev_c7ef8c…` (tbyte, UNVERIFIED).
- Absence: `ev_afce8c7bcf9c2460dde35fdc105f54edddc9cd`,
  `ev_e61ad50edcf1182772d58ffe69049161b001e3df2e24c7242ca1de9a725230f9`,
  `ev_22f807f72b01605f0e6bf0f475b9043726e8c6f1ba2d6a6aa89b5af086a78d1`.
- Carried DEC-VIS-02: `ev_c176cc…`, `ev_a92017…`, `ev_60bc81…`,
  `ev_dcf6cf…`, `ev_08ae0f…`, `ev_2fa0ea…`, `ev_466f40…`, `ev_1c2e6d…`
  (fnd_44 transform); `ev_a52597…`, `ev_78fbca…`, `ev_e09b59…`,
  `ev_7c075b…` (fnd_45 port-approx); `ev_c176cc…`, `ev_8134da…`,
  `ev_c041dd…`, `ev_6ebd3f…`, `ev_98156a…` (fnd_46 Stand/LOD/no-RNG).

[O] facts above are donor bytes/dossier output. [D] are inferences from
them. [U] items (§8, tbyte values, exact 24 B field map, LOD struct,
WithAngle arg use) must not be ported as proven.
