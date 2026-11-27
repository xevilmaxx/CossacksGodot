---
id: DEC-U3-REG-SWEEP-2026-11-26
worker: DEC-U3-REG-SWEEP (subagent in full 1:1 Cossacks 3 donor port)
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U3-REG-SWEEP — class-B static angle U3-REG: U3-REG xref sweep for the live hmap texture identity"
ticket: "Pin t_87f0f3c130b0, multiple passes. Packed CODE search for hmapTex/HeightMapTexUnit/OSWTexture/TextureImage/TOSWRefTextureImage/hmapMin/hmapMax with VAs; xref each to FUN_008520a8/FUN_0082f86c and water binder FUN_00854054 bit row; inspect donor .map read-only for a named height texture/image field; per-map-authored vs generic-engine-layer only if byte-proven. Each still-[U] field gets a GL glBindTexture/glUniform1i dump with zero-mismatch termination. No invented texture id; no parity claim."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_claim: NONE
parity_status: UNVERIFIED
visual_parity_claim: false
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written. Donor .map bytes read with local read-only open(rb)+find only."
scope_guard: "Repo/doc file reads and read-only donor .map byte finds only. No code, shader, asset, config, test, fixture, result JSON, backup, queue file or git state written; no donor binary executed/captured/copied; no Godot process, runner job, gate, harness, replay or port capture run. Exactly one repository file written: this report."
multi_pass: true
upstream: "PORT1TO1_u_classify.md §2.1/§4 B2 (U3-REG whole-binary caller sweep, STATIC-only); DEC_U_hmap_identity.md (chain FUN_008520a8 <- FUN_00739bf8(layerObj) -> FUN_0082f86c(*(h+0x200)) [D]; unit C+0xdc, target C+0xd8, gate C+0xe0; name/id [U]); DEC_U_hmap_num_deep.md §6 U-NUM/U-MAP/U-TEX/U-REG; DEC_U12_deep.md §3 (TOSW*/TextureImage/OSWTexture family); D06_water_shore.md (FUN_00853ad4 key initializer, hmapTex VA/file); D04_map_format.md (TerrainMapBegin layout); DECOMP_04_strings_config.md + DEEPDEC_03_water.md + T6-W01 (CODE-embedded tables/file offsets); variant3d/scripts/water3d.gd + water3d.gdshader (port substitute)"
---

# DEC-U3-REG-SWEEP — packed-CODE registry sweep for the live hmap texture identity (read-only)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU/runtime session was executed by this worker; no parity claim is made. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`.

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim bytes/text/decompiled instruction re-cited from a pinned record, or a new read-only byte-find result from this ticket with exact offsets), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation, never wired), or `[U]` (UNVERIFIED — settling experiment in §6; the port must **hard-fail, never invent a texture name/id, a unit number, or a per-map tuple**). This worker issued **no Craft Anything native lifts** (subagent context: repo/doc reads via default tools + local read-only `open(rb)` byte finds on donor `.map` files only); every donor CODE VA/evidence id below is a **re-cited pinned record** from `D06_water_shore.md`, `DEC_DEEP_water_color.md`, `DEEPDEC_03_water.md`, `DECOMP_04_strings_config.md`, `T6-W01`, `DEC_U12_deep.md`, `DEC_U_hmap_identity.md`, `DEC_U_hmap_num_deep.md`, `D04_map_format.md`, each pinned `document:"t_87f0f3c130b0"`. No donor binary was executed, no GPU frame captured, no parity claimed. Active donor target was never opened/selected/closed by this worker. No helper script was written into the repo; the two local byte-find one-liners ran outside the repo and are quoted verbatim in §4. One repo file written: this report.

`[D]` load-bearing result: **the sweep adds byte-proven negatives and tightens the registry, but recovers zero live texture bytes.** The chain `FUN_008520a8 <- FUN_00739bf8(layerObj) -> FUN_0082f86c(*(h+0x200))` with unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`), gate `C+0xe0` stays `[D]`; **the actual texture object name/id at runtime remains `[U]`**, exactly as the ticket states. Nothing below promotes a name, a unit, a size, or a per-map tuple to `[D]`.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

No function exceeded budget. This ticket performed **document/byte-record re-analysis + two new read-only donor `.map` byte-find passes only** — no new decompilation, no execution.

| # | Question / function | Passes this ticket | Result |
|---|---|---|---|
| R1 | Packed-CODE names `hmapTex/hmapW/hmapMin/hmapMax` VAs + file offsets + assignment site | 1 re-read: `D06_water_shore.md` P4/P6/P7/P10/P13 §§2–3 + `DEC_DEEP_water_color.md` + `DEEPDEC_03_water.md` §2.1 + `DECOMP_04_strings_config.md` §8 | **Accepted**: single-hit `hmapTex` VA/file, descriptor fields `+0x54/+0x58/+0x5C/+0x60/+0x64`, initializer `FUN_00853ad4`, setter `FUN_00405454` (§2) |
| R2 | `HeightMapTexUnit` + `MirrorTexUnit/NormalTexUnit/DiffuseTexUnit/CustomReflectionUnit` key block | 1 re-read: `T6-W01.md` §3.1 (file offsets) + `DEC_U_hmap_identity.md` §3 (`water.lib` absence) | **Accepted as bounded**: key name byte-proven at file offset; numeric value absent everywhere; no VA recovered → VA/value `[U]` (§2) |
| R3 | `OSWTexture` / `TextureImage` / `TOSWTextureImage*` / `TOSWRefTextureImage` CODE family | 1 re-read: `DEC_U12_deep.md` §3 (counts + VAs + 512 B windows) + `DEC_U_alpha_pass_quad.md` (`tia*` RTTI control) | **Accepted as localized**: Delphi published-property family byte-proven; no ctor→field-store link recovered → all links `[U]` (§2) |
| R4 | Xref of each §2 candidate to `FUN_008520a8` / `FUN_0082f86c` and binder `FUN_00854054` bit row | 1 re-read: `DEC_U_hmap_identity.md` §§4–5 + `DEC_U_hmap_num_deep.md` §§3–4 + `D06_water_shore.md` §3 | **Accepted**: schema→slot mapping `[D]`; direct call-edge xref absent in corpus (builtin DB 0 refs) → whole-binary enumeration `[U]` (§3) |
| R5 | Donor `.map` read-only inspection for a named height texture/image field with stored id (angle c) | 2 new read-only byte-find passes: `ausmis1.map` (43,950,027 B) + `battle1.map` (56,117,715 B), `open(rb)` + `find/count` only, zero writes, zero execution | **Accepted, decisive negative**: 0 hits for all 7 registry names; only `Image` hits are `TScenarioImage` briefing structs; only `.bmp` hit is the `ausmis1.map.bmp` preview reference (§4) |
| R6 | Per-map-authored vs generic-engine-layer verdict (angle d) | 1 synthesis pass over R1–R5 + `D04_map_format.md` terrain-block layout + `water.lib`/`water.mat` registry facts | **Accepted**: neither hypothesis byte-proven; verdict stays `[U]` with two discriminating GL hypotheses (§5) |
| R7 | Port file re-read (stance, no edits) | 1 read: `variant3d/scripts/water3d.gd` hmap rows (prior cites `:68,450-458,611-633,624-633`) | **Accepted as `[O]`**: substitute + `[U3]` labels verified present; no line touched (§7) |

No `wgl`/FBO/`glTexImage2D` water-anchored hit is added by R1–R7; that absence is bounded by the re-read corpus plus the two `.map` specimens, not a whole-binary proof.

---

## 2. Angle (a) — packed CODE byte search: all seven property names with VAs [O]/[D]/[U]

All CODE VAs below are **re-cited pinned records** (`t_87f0f3c130b0`); file offsets are `cossacks.exe` file offsets. `VA = file + 0x400C00` per `D06_water_shore.md` P8 holds for the water-schema row. A dash means no VA was recovered in the cited corpus — recording a VA there would be invention.

### 2.1 Water-schema keys (`FUN_00853ad4` initializer family)

| # | Name | VA `[O]` | File offset `[O]` | Hits / header `[O]` | Descriptor field `[D]` | Standing |
|---|---|---|---|---|---|---|
| A1 | `hmapTex` | `0x853e0c` | `0x45320c` (dec 4534796, `T6-W01` §3.1) | **1 match**, whole exe (`D06` P4, prior `ev_1bd891e2…`); Delphi AnsiString header `ffffffff 07000000` immediately before it | `+0x54` (`lea eax,[ebx+0x54]; mov edx,0x853e0c; call 0x405454` at VA `0x853bdb` / file `0x452fdb`, pattern `8d 43 54 ba 0c 3e 85 00` unique, `D06` P6/P13) | Name + assignment site `[D]`; binding/shader use `[U]` |
| A2 | `hmapW` | `0x853e1c` | adjacent (`DEC_DEEP_water_color.md` re-read) | schema-order key after `hmapTex` (`DECOMP_04` §8 key order) | `+0x58` (`D06` §3.1; `FUN_00853ad4` 30-key run `+0x04…+0x78`) | Field offset `[D]`; live value `[U]` |
| A3 | `hmapH` | — (contiguous, not individually quoted in corpus) | — | schema-order key (`DECOMP_04` §8: `…hmapTex, hmapW, hmapH, hmapMin, hmapMax…`) | `+0x5C` (`D06` §3.1) | Field `[D]`; VA unquoted → VA `[U]` (bounded) |
| A4 | `hmapMin` | `0x853e3c` | schema window `0x853d00–0x8556e4` (`DEC_01_binaries_rtti.md:313`; `DEEPDEC_03_water.md` §2.1 `+0x60 → 0x853e3c`) | schema key; setter `FUN_00405454(param_1 + 0x60, "hmapMin")` (`DEC_DEEP_water_color.md:44`; `D06_water_shore.md:237`) | `+0x60` | Key + setter `[D]`; default/value `[U]` (binary default UNVERIFIED, `DEEPDEC_03` §2) |
| A5 | `hmapMax` | `0x853e4c` | same schema window (`DEEPDEC_03` §2.1 `+0x64 → 0x853e4c`) | schema key; setter `FUN_00405454(param_1 + 100, "hmapMax")` (`+100 = +0x64`; `DEC_DEEP_water_color.md:45`; `D06_water_shore.md:238`) | `+0x64` | Key + setter `[D]`; default/value `[U]` |
| A6 | `HeightMapTexUnit` | — (no VA in corpus) | dec **4530052** (`T6-W01` §3.1, uniform-name table region `…MirrorTexUnit/NormalTexUnit/DiffuseTexUnit/HeightMapTexUnit…`) | 1 name hit in table; **numeric unit values do not appear in adjacent plaintext** (`T6-W01` §3.1 verbatim) | none recovered (absent from `water.lib` 71 lines, `DEC_U_hmap_identity.md` §3) | Name `[O]`; VA, value, and any link to `C+0xdc` all `[U]` |

`[D]` The five `hmap*` names form one coherent **parameter-schema initializer**: `FUN_00853ad4` (Ghidra Deep pseudo `ev_4ddab2a…`) assigns 30 string keys into `[obj+0x04…+0x78]` with the `hmap*` run at `+0x54…+0x64` plus global `f32 1.99999988` (`0x853eb8`) into `+0x7c` (`D06` P8/P10). The only proven operation is **string assignment** (`mov edx,<key>; call 0x405454`); **no texture lookup, sampler unit, or GPU bind is present in that function** (`D06` §3.1 finding 1). `HeightMapTexUnit` sits in a second key block (`MirrorTexUnit @4530128 / NormalTexUnit @4530152 / DiffuseTexUnit @4530176 / HeightMapTexUnit @4530052 / CustomReflection @4529788` file offsets, `T6-W01`) whose values are likewise absent.

### 2.2 `TOSW*` / `TextureImage` / `OSWTexture` CODE family (Delphi RTTI)

| # | Name | VA/count `[O]` (re-cited `DEC_U12_deep.md` §3) | Window `[O]` | Standing |
|---|---|---|---|---|
| A7 | `TOSWTextureImage` | **4 matches**: `0x4e6e2a`, `0x4e6f99`, `0x4e6fb2`, `0x4e7101` | `0x4e6e00` (512 B): `…textureFileName.String… TOSWTextureImageAlpha … tiaDefault.tiaAlphaFromIntensity… OSWTexture…` — Delphi published-property block | Family localized `[D]`; any role in hmap path `[U]` |
| A8 | `TOSWTextureImageToN` | **1 match**: `0x4e6fb2` | `0x4e6f60` (512 B): `…TOSWTextureImage … TOSWTextureImageToN … OSWTexture … TOSWRefTextureImage …` | Same; `[U]` for hmap |
| A9 | `TOSWRefTextureImage` | inside `0x4e6f60` + `0x4e7000` windows (`…TOSWRefTextureImage … TOSWTextureImageEditor … TOSWBlankImage…`); **no standalone VA quoted** | `0x4e7000` (512 B) window re-cited verbatim | Suggestive name only `[I]`; backer identity `[U]` — **must not** be recorded as the reflection/hmap backer |
| A10 | `TextureImage` | **8 matches**: six in CODE `0x4e6e2e–0x4e7105`, one at `0x770bab`, one in `.rsrc` `0x9586df` | class-registration region inside giant init routine `sub_4e72f8` (`0x4e72f8–0x4e91…`) | `[D]` registration metadata; `[U]` for hmap |
| A11 | `OSWTexture` | **59 matches** (first page `0x4bf406, 0x4bf41f, 0x4e6c98, 0x4e6d2a, 0x4e6e2b, 0x4e6efb, 0x4e6f9a, 0x4e6fb3, 0x4e6fcd, 0x4e70a4`) | `0x4e7e80` region inside `sub_4e72f8`: `…TOSWTexture … OSWTexture … ImageClassName … Image … ImageAlpha…` | `[D]` engine class family; `[U]` for hmap |
| A12 | control | MSVC RTTI prefix `.?AV` = **0 matches** (`DEC_U12_deep` §3) | whole-file `native_bytes_find` | `[D]` Delphi-style classes, not MSVC — consistent with `TComponent`-style registration |

`[D]` The metadata is Delphi-style (class names + published properties interleaved with init code in `CODE`), not MSVC. `[U]` No new or re-read pass links **any** `TOSW*` constructor (or `ImageClassName` factory) to the water shader object field `C+0x4c` (reflection slot, GL id at `+8`), let alone to the hmap slot `C+0xe0`. Concretely missing: (i) instantiating class for either slot; (ii) width/height/format/mipmap args; (iii) `TOSWRefTextureImage` vs `TOSWBlankImage` vs plain `TOSWTextureImage` for either slot; (iv) the store call site. A whole-binary constructor→field-store sweep (each `TOSW*` vtable + `ImageClassName` factory, ≤5 passes each) remains open → §6 U-REG-TEX.

---

## 3. Angle (b) — xref of each candidate to `FUN_008520a8` / `FUN_0082f86c` and the water binder `FUN_00854054` bit row

### 3.1 Proven draw-time chain (re-cited `[D]` backbone)

`FUN_008520a8(shaderCtx=C, layerObj, field)` (`ev_ada1…`, `DEC_U_hmap_identity.md` §4.1), verbatim re-read R4:

```
if (layerObj==0 || waterDesc==0 || layerDesc+0xb9 == 0)  // HeightMapEnable (water.lib:60 via descriptor ev_8d76…)
    C+0xe0 = 0;                                   // height path closed
else:
    h = FUN_00739bf8(layerObj)                    // VA 0x739bf8: terrain/layer handle lookup
    C+0xe0 = FUN_0082f86c(*(h+0x200))              // VA 0x82f86c: engine height object
    C+0xd8 = *(h+0x50)                             // texture target (ctor default 0xde1)
    C+0xd0 = *(layerObj+8)                         // hmapW  → bit 7e.20
    C+0xd4 = *(layerObj+0xc)                       // hmapH  → bit 7e.40
    C+0xe4 = (float) FUN_0082f060(*(h+0x200))      // VA 0x82f060: hmapMin → bit 7e.80
    C+0xe8 = (float) FUN_0082f114(*(h+0x200))      // VA 0x82f114: hmapMax → bit 7f.01
```

`FUN_00854054` hmap rows (`ev_ab75…` / raw `ev_bbdb…` at VA `0x854054–0x8542f0`), re-read:

```
7e.10 hmapTex: glUniform1i(loc, C+0xdc)   // sampler UNIT, ctor default 2 (FUN_00856080 ev_5aae…)
7e.20 hmapW:   glUniform1i(loc, C+0xd0)
7e.40 hmapH:   glUniform1i(loc, C+0xd4)
7e.80 hmapMin: glUniform1f(loc, C+0xe4)
7f.01 hmapMax: glUniform1f(loc, C+0xe8)
gate at VA 0x854250: bind 7e.10–7f.01 ONLY IF C+0xe0 != 0 && [C+0xe0+8] != 0
```

`[D]` `hmapW/H` are verbatim `int32` copies; `hmapMin/Max` are verbatim float passthroughs (`(float)` cast then `push [C+0xe4]/[C+0xe8]` to the `glUniform1f` wrapper `FUN_004c0f90`, ptr `0x8fc724`); **no donor-side scale, bias, or metres↔texel conversion** sits between getter and uniform in the recovered code.

### 3.2 Per-candidate xref standing

| Candidate | Xref to `FUN_008520a8` / `FUN_0082f86c` | Xref to binder `FUN_00854054` bit row | Verdict |
|---|---|---|---|
| `hmapTex` (A1) / `hmapW/H/Min/Max` (A2–A5) | **Indirect, schema-mediated `[D]`**: the names are assigned by `FUN_00853ad4` into descriptor slots `+0x54…+0x64`; the draw path reads *engine words* (`layerObj+8/+0xc`, getters on `+0x200`-object) into shader slots `C+0xd0/d4/e4/e8` and binds them at bits 7e.10–7f.1. No recovered instruction in `FUN_008520a8` references the `0x853e0c/1c/3c/4c` string VAs directly; the link is offset/shape correspondence (`+0x54↔7e.10`, `+0x58↔7e.20`, `+0x5C↔7e.40`, `+0x60↔7e.80`, `+0x64↔7f.01`) plus the DEV shader's uniform declarations (`water.dev.frag:18-21`). Direct call-edge xref: **0 refs** in builtin DB (`D06` P12 `native_xrefs_list(0x853e0c)` = 0; rejected as xref limitation because the reference is an immediate operand in the undiscovered region — P13 pattern find proves the site instead) | Bits 7e.10–7f.1 proven consumers of `C+0xdc/d0/d4/e4/e8`; the *string* VAs have no recovered xref into `0x854080–0x8542f0` raw bytes | Schema→slot `[D]`; whole-binary caller/xref enumeration `[U]` → §6 U-REG |
| `HeightMapTexUnit` (A6) | No recovered xref to `FUN_008520a8`, `FUN_00739bf8`, or `FUN_0082f86c`; file lives outside the draw chain; `water.lib` carries no such key | No recovered xref to `C+0xdc` or bit 7e.10; live unit is ctor default `C+0xdc=2` (`FUN_00856080`) unless overwritten by code not in corpus | Fully `[U]` → §6 U-REG-TEX (unit sub-row) |
| `TOSW*` / `TextureImage` / `OSWTexture` (A7–A11) | No recovered caller→field-store edge into `C+0xe0` (hmap slot) or `C+0x4c` (reflection slot); `sub_4e72f8` registration region has no recovered call into `FUN_008520a8`/`FUN_00854054`/`FUN_00603d30` | No recovered `glTexImage2D`/FBO-attachment call inside `FUN_008520a8`/`FUN_00854054` from the re-read corpus (`DEC_U_hmap_identity.md` §2 `ev` table note) | Fully `[U]`; names suggestive only `[I]` → §6 U-REG-TEX |
| `FUN_0082f060` / `FUN_0082f114` getters | **Only recovered caller is `FUN_008520a8`** (VA `0x8520a8`); no map/terrain-loader or texture-registry caller in `DEC_U_water_runtime.md` §5 / `DEC_U_water_capture.md` Phase 4 / `PORT1TO1` §§4/7 re-read corpus; no literal min/max argument at the recovered call sites | Consumed only via `C+0xe4/+0xe8` at bits 7e.80/7f.01 | One caller `[O]` bounded; whole-binary list `[U]` → §6 U-REG |

`[D]` No evidence id in the re-read corpus anchors a second static caller of `0x82f060`/`0x82f114`, a map-file height-table address, or a `glTexImage2D`/`glBindTexture`/FBO-attachment call **inside** `FUN_008520a8` / `FUN_00854054` / `FUN_00603d30`. The gap is fenced, not filled.

---

## 4. Angle (c) — donor `.map` read-only inspection: no named height texture/image field [O]/[D]

New read-only passes this ticket (local `open(...,'rb')` + `find`/`count`; donor binary never executed; no donor file written, copied, or committed):

- Specimens: `C:\Games\Cossacks 3\data\maps\missions\ausmis1.map` (43,950,027 B) + `battle1.map` (56,117,715 B). Directory holds 31 `.map` + 31 `.aix` (`DEC_U_hmap_num_deep.md` §2.1 re-cited; listing re-verified this ticket).
- Byte-find results, exact:

| Needle (ASCII) | `ausmis1.map` count / first | `battle1.map` count / first | Standing |
|---|---|---|---|
| `hmapTex` | **0 / NONE** | **0 / NONE** | `[O]` absent from both specimens |
| `HeightMap` | **0 / NONE** | **0 / NONE** | `[O]` absent (covers `HeightMapTexUnit`, `HeightMapEnable`, `HeightMapWaves0` spellings) |
| `TOSW` | **0 / NONE** | **0 / NONE** | `[O]` absent (covers `TOSWRefTextureImage`, `TOSWTextureImage*`, `TOSWBlankImage`) |
| `TextureImage` | **0 / NONE** | **0 / NONE** | `[O]` absent |
| `OSWTexture` | **0 / NONE** | **0 / NONE** | `[O]` absent |
| `hmapMin` / `hmapMax` | **0 / NONE** each | **0 / NONE** each | `[O]` absent |
| `heightmapwaves0` | **0 / NONE** | **0 / NONE** | `[O]` absent — independent of the `water.mat:86-106` commented block |
| `TerrainMapBegin` | **1 @ file 19882990** (`…TerrainMapBegin 40 01 00 00 40 01 00 00…` = W=320 H=320 LE `u32`) | **1 @ file 30285006** (`…TerrainMapBegin 80 01 00 00 80 01 00 00…` = W=384 H=384) | `[O]` single terrain block each; extents match D04 specimens (bonmis1 320 / battle1 384) |

- Disambiguation of the only near-hits (`[O]`):
  - `Image` = **4 hits each**, all `TScenarioImage` mission-briefing structs (`TScenarioQuery[256]` / `TScenarioImage[64]` / `TScenarioResult[256]` scaffolding at `ausmis1.map` ~12133104–12134099, `battle1.map` ~4309741–4310736; fields `name:string`, `material:string`). **Not** a height texture/image field; scenario UI only.
  - `.bmp` = **1 hit in `ausmis1.map` @16009960** (`…0b ausmis1.map 04 .bmp 04 .lng 07 ausmis1 … ausmis1.name … ausmis1.description…`, `TInterfaceC`/`TScenario` block) = the scenario **preview-bitmap reference** (`ausmis1.map.bmp` + `.lng`), not terrain data. `battle1.map` has 0 `.bmp`. `.tga` = 0 both; `.dds` = 0 both; `height`/`Height`/`Texture`/`Material` = 0 both (case-sensitive finds).
- Terrain-block context re-cited `[D]` (`D04_map_format.md` §§2–5): `u32 W, u32 H, u8 sub=4, u32 tilepx=64 → (2W)×(2H) u32 tag grid → 41-byte gap → u32 W, u32 H → LE f32 height grid → W×H 37-byte records (24 B + 13 B)`. The height grid is a flat `f32` array (count anomaly `(W+1)^2−2` vs writer loop `(W+1)^2`, D04 U1); it carries **no per-grid min/max header** and the 37-byte records carry **no float min/max pair and no dimension pair** at any record-relative `+8/+0xc/+0x200`. The engine offsets `layerObj+8/+0xc`, `h+0x50`, `h+0x200` are **runtime object-field offsets in `FUN_008520a8`**, not map-file field positions — no static file→word link is recovered (re-cited `DEC_U_hmap_num_deep.md` §2.2).

`[D]` The `.map` terrain payload therefore names **no height texture object, no GL name, no dimensions-as-text, and no min/max pair**. Whatever the live `C+0xe0` texture is, its name/id is **not stored as a byte-proven string or id field in the two shipped-map specimens**; it is produced at load/draw time by engine code (`FUN_00739bf8` → `FUN_0082f86c` → getters), whose internals remain `[U]`.

---

## 5. Angle (d) — per-map authored object vs generic engine layer: verdict stays [U]

Question: is the live `C+0xe0` texture a **per-map authored object** (baked at map build, shipped per `.map`) or a **generic engine layer** (one heightfield pipeline reused for every map)?

| Hypothesis | What would byte-prove it | What this sweep found |
|---|---|---|
| H1 per-map authored texture object | A named texture/image field (or stored GL-size/format/id) inside `.map` bytes, varying per map; or a per-map loader branch writing `h+0x50`/`h+0x200` | **Absent**: §4 zero-hits for every registry spelling in both specimens; §2 A6–A11 no per-map filename/registry value; D04 layout has no such field. H1 is **not proven** |
| H2 generic engine height layer | A single construction/upload site (one `TOSW*` ctor class, one `glTexImage2D`/FBO path) feeding `C+0xe0` for all maps; same `(target, provenance)` across maps with only size/min/max varying | **Absent**: no ctor→`C+0xe0` store, no upload/copy call, no size/format literal recovered in corpus (§§2–3). H2 is **not proven** |

`[D]` Only the negatives are byte-proven: (i) map bytes carry floats + tile records, not a texture object; (ii) `water.lib` contributes exactly one live hmap fact (the `HeightMapEnable=True` gate bit); (iii) `water.mat` contributes zero live hmap facts (`HeightMapWaves0` fully commented, `heightmapwaves0.tga` alpha-255 disproved as `hmapTex.w`); (iv) min/max are getter outputs at draw time, not stored headers. **The H1-vs-H2 choice is therefore `[U]`** — recorded as two discriminating GL hypotheses in §6 (same `(target, provenance)` across two maps + move ⇒ H2 gains; per-map `(name, w, h)` ⇒ H1 gains; either way no claim until zero-mismatch termination).

No invented texture id. No parity claim. No `HeightMapTexUnit` number. No `TOSWRefTextureImage = backer` equation (name suggestive only `[I]`).

---

## 6. `[U]` register — GL texture-binding/uniform dumps with zero-mismatch termination

Gating precondition for **every** row: water field visible (break `FUN_00603d30` @ `0x603d30`, read `[ebp+0x1c]`); live path identified first (hook `glShaderSource`: `hmapTex` present = DEV file pair `water.dev.vert/frag` per `water.lib:67-68`; `alphaDepth`/`deepColor` = BUILTIN embedded pair); height gate open at `0x854250` (`C+0xe0 != 0 && [C+0xe0+8] != 0` — closed gate voids the frame). Owner-authorised donor session only; forbidden to workers. Captures on the BUILTIN path settle nothing.

| # | Still-`[U]` item | Static state after this sweep | Capture experiment (break + trace + byte comparison) | Zero-mismatch termination |
|---|---|---|---|---|
| U3-TEX | `hmapTex` GL identity `(target, name, w, h)` + provenance class | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`, per-draw `*(h+0x50)`); `[U]` name/provenance/size. Registry names (§2) give **no id**; `.map` bytes (§4) store **no id** | At the `FUN_00854054` 7e.10 break (same draw as the U3-NUM tuple): record `glActiveTexture(GL_TEXTURE0+u)` with `u=C+0xdc`, `glBindTexture(target,name)`, `glUniform1i(hmapTex,u)`, `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})` + sampler state; full-frame history of `name`: (a) FBO attachment (`glFramebufferTexture2D*` with that name), (b) copy dst (`glCopyTexImage2D/SubImage2D`), (c) upload-only (`glTexImage2D` with that size). Dump one 8×8 texel block + channel carrying height; log map name + `water.lib` hash | **Terminate iff the same `(target,name,w,h)` repeats with 0 mismatches across ≥2 frames + 1 camera move** on that map, and exactly one provenance class (a/b/c) accounts for `name` with 0 counter-examples. Mixed/unknown provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`; never promote art/`heightmapwaves0.tga`/neutral texel |
| U3-NUM | Live `(hmapW,hmapH,hmapMin,hmapMax)` for a named shipped map | `[D]` sources: `layerObj+8/+0xc` int32 copies; `(float)FUN_0082f060/0082f114(*(h+0x200))` identity passthrough; gate proven. Values per-map `[U]` | Break `FUN_00854054` bits 7e.10–7f.1 (`0x854250–0x8542f0`) with the named map loaded + field visible. Record pushed `C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats **plus** chain pointers (`layerObj`, `h`, `h+0x200`, `C+0xe0`, `[C+0xe0+8]`) and same-draw `glUniform1i/1f` hook values on `hmapW/H/Min/Max`. Name the map + `water.lib` hash | **Terminate iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move** on that map; those 4 numbers (not `map_size`/`±2.96`/`±2.964`/clamp) become the port parameters **for that map only**. A second map needs its own row |
| U-MAP | Map byte-dump ↔ live-tuple linkage (does file W/H or grid min/max predict the uniform?) | `[D]` file W/H headers + flat `f32` grid + clamp `±2.9639999866` (D04 specimens); `[O]` this-ticket `ausmis1` W=320 / `battle1` W=384 headers; `[U]` file→engine-word mapping | With the same map loaded, dump terrain-block W/H headers + full `f32` grid (min, max, mean, histogram) per D04 §5 recipe, compare against the same-session U3-NUM tuple. Hypotheses in order: (i) `hmapW/H == file W/H`; (ii) `hmapMin/Max == file grid min/max`; (iii) neither | **Terminate iff one hypothesis holds with 0 mismatching bits/floats** across the dumped map + U3-NUM frames, else record `neither` and keep the substitute. Never overwrite file bytes to force a match |
| U-REG | Whole-binary callers of `0x82f060`/`0x82f114` + writers of `h+0x50`/`h+0x200` (loader/registry internals) | `[O]` one caller (`FUN_008520a8`); loader/registry `[U]` | Static-only sweep (no GPU): xref `0x82f060/0x82f114/0x739bf8/0x82f86c`; decompile each new caller (≤5 passes each); record VA + sampled disassembly + which caller writes `h+0x50`/`h+0x200` and any reachable `glTexImage2D`/FBO writer | **Terminate iff every xref is visited with 0 unvisited xrefs remaining** in tool output. Until then loader prose stays `[U]` |
| U-REG-TEX | `TOSW*` ctor→field-store sweep (`C+0xe0` hmap slot + `C+0x4c` reflection slot) + `HeightMapTexUnit`→`C+0xdc` override check | `[O]` family localized (§2.2: `TOSWTextureImage×4`, `ToN×1`, `TextureImage×8`, `OSWTexture×59`, `TOSWRefTextureImage` in-window); `[U]` every store edge and the unit override | Static-only: walk each `TOSW*` vtable + `ImageClassName` factory; record instantiating class, w/h/format/mipmap args, store VA into `C+0x4c`/`C+0xe0`; scan for any immediate write to `C+0xdc` other than ctor `2`; record `HeightMapTexUnit` string VA (when recovered) and every code xref of it | **Terminate iff each class has a visited ctor with 0 unvisited xrefs remaining** and the `C+0x4c`/`C+0xe0`/`C+0xdc` writers are identified (or proven absent) with 0 unvisited xrefs. Until then `TOSWRefTextureImage` stays suggestive `[I]`; `HeightMapTexUnit` stays valueless `[U]` |

General rule: any mismatch, closed gate, or wrong-shader-path capture voids the frame. No parity follows from termination — termination only authorises wiring the captured reals for the captured map/slot.

---

## 7. Exact port stance (file:line; NO edits made — owner applies)

All lines re-cited at repo HEAD via prior tickets; verified present, untouched by this worker. **Wire only captured reals.**

1. `variant3d/scripts/water3d.gd:68` (`MAX_HEIGHT=2.96`), encode `:652`, `hmapMin/Max` binds `:668-669`, `max_height :763` — KEEP SUBSTITUTE + `[U3]` LABELS. After U3-NUM on the target map only: replace `∓MAX_HEIGHT` in encode and decode with the captured `(hmapMin,hmapMax)`, keeping DEV shape `hmapMin + w*(hmapMax-hmapMin)`. FORBIDDEN: presenting `±2.96`/`±2.964`/clamp/`k_ravine_1` numbers as recovered.
2. `variant3d/scripts/water3d.gd:486+` (`bind_height_grid`), `:655` (`height_tex`), hmap binds `:663-669` — KEEP SUBSTITUTE. After U3-TEX only: add `bind_engine_hmap(real_texture, target_enum)` from captured provenance; never generated solid-colour, never `diffusewaves*`/`heightmapwaves0` art unless a capture proves identity.
3. Uniform-table `:143,146-147`, stats `:305,346`, ledger `:909,913,940` — LABEL-ONLY: cite this sweep (`FUN_008520a8 → FUN_00739bf8 → FUN_0082f86c → FUN_0082f060/114`; unit `C+0xdc` ctor 2; target `C+0xd8` ctor `0xde1`; gate `0x854250`; schema `FUN_00853ad4 +0x54…+0x64`; `hmapTex @0x853e0c` single-hit; `HeightMapTexUnit` valueless; `TOSW*` unlinked; `.map` zero-hit §4); keep every `[U3]` tag.
4. FORBIDDEN: hard-coding any shipped-map `(W,H,Min,Max)` from `map_size`, `128`, `2.96`, `2.964`, `±2.9639999866`, `−1.1`, `0.495`, `0.1/0.01`, `512`, or forum values; inventing a `HeightMapTexUnit` number; inventing a texture name/id; emulating `[C+0xe0+8]` as a GL name; adding a scale/bias between getters and uniforms; equating `TOSWRefTextureImage` with the backer from the class name alone.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU/map-live capture performed. All live numbers and the texture id stay `[U]` pending §6. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; six-condition chain per `PORT1TO1_u_classify.md` stays 0/6 CLOSED as far as this sweep is concerned.
- **No approximation substituted.** No shipped-map `(W,H,Min,Max)` tuple, no texture name/size/unit, no conversion factor is supplied. The port's decoded-grid `height_tex`/`hmapTex` + `±2.96` span, both explicitly labelled `[U3]`, is endorsed as the donor-faithful behaviour until the corresponding zero-mismatch captures land.
- **No invented texture id.** The H1-vs-H2 verdict (§5) is `[U]` precisely because neither a per-map authored object nor a generic engine layer is byte-proven; §4's zero-hit table is evidence of absence *in the searched bytes*, not a license to pick H2 by default.
- **Read-only compliance.** Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U3_reg_sweep.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed; donor `.map` files were read with `open(rb)` + `find`/`count` only and never copied into the repo.
- **Claim register (audit-level):** (1) seven-name packed-CODE table with VAs/file-offsets/hit-counts re-cited + two bounded VA gaps marked `[U]` — `[O]`/`[D]` this sweep; (2) schema→slot xref `[D]`, whole-binary caller/xref enumeration `[U]` — `[D]`; (3) two-specimen `.map` zero-hit table + `TScenarioImage`/preview-`.bmp` disambiguation + W=320/384 headers — `[O]` new; (4) H1-vs-H2 `[U]` verdict — `[D]` from (1)–(3); (5) five GL/static experiments with zero-mismatch termination — `[D]` protocol, unexecuted; (6) no parity, no value closed, no `[U]` promoted — `[O]` scope guard.

*End of DEC-U3-REG-SWEEP.*
