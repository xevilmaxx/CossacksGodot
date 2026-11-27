---
id: DEC-U-SHORE-ALPHA
wave: TERRAIN-SWARM-2026-11-26 (full 1:1 donor port, worker DEC-U-SHORE-ALPHA)
ticket: "Shore alpha confinement/proximity constants; which alpha patch indices near water; GL_ALPHA_FUNC comparator/ref per blend mode; intensity→alpha feed"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U, "RUNTIME PROBE", "PORT INSTRUCTION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; no donor binary executed, copied, committed, modified or debugged)"
target: "cossacks.exe t_87f0f3c130b0 (sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16) — pinned on EVERY native call cited from prior passes; this worker opened no new native target and executed no donor binary"
secondary: "editor.exe t_68474ddde43f — NOT opened or used by this worker"
scope_guard: "Donor READ ONLY. Exactly one repo file written: this report. No code/shader/config/asset/test/Godot/git edit. No Craft Anything brief/hypothesis/finding/unknown mutation."
parity_claim: false
multi_pass: true
prior_art: "PORT1TO1_water_shore.md (§§4/9/11 U10/U12), DEC_U_alpha_pass_quad.md (§§3/4/8-9), X17_blendfunc_verification.md (§3.1-3.2), X28_shore_tile_vectors.md (§§3.2-3.3), D08_tile_select_bin.md (§3.5), F05_tile_mapping.md (§3), F06 reports (E3/E7-E11), PORT1TO1_terrain_renderer.md (§§3.5/5.1/5.4)"
---

# DEC-U-SHORE-ALPHA — shore alpha confinement / patch rule / GL alpha func / intensity→alpha

## 0. Executive summary — verdict per [U]

| Item | Prior status | This pass | Result |
|---|---|---|---|
| **shore `alpha_confine` constant** (`features.water.alpha_confine=true`) | [U] in PORT1TO1 §11 (blend factors/pass count U10) context; port config preserves value | **NO DONOR CONSTANT FOUND [U] — port-only gate** | `config.gd:66-67,456-460`, `water3d.gd:734-739,1002-1004` consume it as telemetry only; `terrain_donor_mesh.gd` / `terrain_donor_shader.gdshader` contain zero references (grep §1.2 P6). No donor text, enum, table or `glAlphaFunc` call cited in any prior pass establishes a confine threshold. Do not bake `true` as donor truth. |
| **shore `shore_prox` constant** (`features.water.shore_prox=false`) | [U]; port config preserves value | **REMOVED PORT ART [O-port] / NO DONOR CONSTANT [U]** | `water3d.gdshader:533` comment + `water3d.gd:1002` telemetry + `config.gd:67,459-460` + `tests/t_terrain_shore.gd:926-935` agree it is absent from donor `water.dev.frag:227`. No donor proximity radius/weight exists in `texturemap.inc:463-472` (gate is height+mask only). Do not reintroduce. |
| **which alpha patch indices are used near water** | [U] left open by PORT1TO1 §9.4 / §11 U10 | **RULE RECOVERED [O]/[D]; per-cell index stays [U] without mask+variant** | Near-water overlays use `p = ALPHA_index(mask,variant)` = `DAT_008f5d00` pair table (16 lows + `+16` on `variant&1`), i.e. the 32-entry set `{0..15,16..31}` addressed by `(mask&0xff, variant&1)`; base layer uses `p∈{0,16}` only (both authored constant 255). Shore tile ids near water are exactly `sandsea1=93 / sandsea5=97 / sandsea6=98` (X28 §3.3, F05 §3). No single "shore patch number" exists — inventing one is prohibited. |
| **GL_ALPHA_FUNC comparator/ref per blending mode** | PARTIAL (DEC_U_alpha_pass_quad closed ENABLE, left leak U6b) | **CLOSED STATICALLY [O] for all 6 cases; terrain case has NO comparator** | `sub_4ef810` @0x4ef810 (`ev_c6b5ab46…`): cases 0-5 byte-proven (§4). `bmTransparency` (terrain, case 1) issues **no `glAlphaFunc`** — comparator/ref is whatever the GL default or a leaked case-3/4 call left. Cases 3/4 use `glAlphaFunc(GL_GEQUAL=0x206, 0.5f / 1.0f)`. |
| **`tiaAlphaFromIntensity` arithmetic → alpha feed** | [U] left open by DEC_U_alpha_pass_quad §3/§8 U4b | **STILL [U]; feed path CLOSED [O]/[D]** | Enum value `1` of `TOSWTextureImageAlpha` [O] (`ev_5b7d6bb8…`, `ev_c8049f68…`); conversion arithmetic [U] with exact upload probe (§5). Terrain fragment feed is `color.a = texUnit1.a` (`hf.pvl.smx3.frag:50`, X17 §3.2) — no intensity math on the alpha channel. Donor `water.dev.frag` computes `intensity` (luma) for `watercolor` ONLY; its `ALPHA = coastfade2`, never `intensity`. |

**No donor parity claim is made. No donor GPU frame exists; no donor binary was run. No threshold or patch index is invented in this report.**

---

## 1. Target discipline and multi-pass ledger

### 1.1 Discipline

- Active target for every donor byte-citation reused here is `t_87f0f3c130b0` as recorded in PORT1TO1 §1 (`core_session_show`, `document:"t_87f0f3c130b0"` on every pinned call) and DEC_U_alpha_pass_quad §1.1 (pin on every `native_*` call, `editor.exe` never read). This worker issued **zero** native calls and executed **zero** donor binaries; all donor facts below are re-citations of those pinned evidence ids with VA/file:line, plus fresh read-only port-file reads (which need no donor target).
- Donor text paths are cited as `data/...` and `0x...` VAs from the prior passes, not re-read by absolute path in this pass.
- Port files were read read-only: `variant3d/config.json:33-36`, `variant3d/config_donor_capture.json:34-37`, `variant3d/scripts/config.gd:66-67,456-460`, `variant3d/scripts/water3d.gd:734-739,1002-1004`, `variant3d/shaders/water3d.gdshader:533`, `variant3d/scripts/terrain_donor_mesh.gd` (consts + `_alpha_index` + telemetry), `variant3d/shaders/terrain_donor_shader.gdshader:38-49,70-104,294-326`, `variant3d/tests/t_terrain_shore.gd:926-935`.

### 1.2 Multi-pass ledger (owner rule: ≤5 passes per function/question; all logged)

| # | Question | Passes | Result / accepted? |
|---|---|---|---|
| P1 | Does any donor constant back `alpha_confine`? | 1: grep `alpha_confine\|shore_prox` over `variant3d/` (87 hits) | **Accepted**: only port config/getter/telemetry hits; zero hits in `terrain_donor_mesh.gd` / `terrain_donor_shader.gdshader`. No donor VA/text cited in PORT1TO1/DEC_U/X17/D08/F06 establishes one. |
| P2 | Does any donor constant back `shore_prox`? | 1: same grep + `water3d.gdshader:533` + `water3d.gd:1002` + `config.gd:67` + `t_terrain_shore.gd:926-935` | **Accepted as PORT ART REMOVED [O-port]**: unanimous port-side labelling; donor `water.dev.frag:227` has no proximity multiplier (PORT1TO1 §5.1 verbatim). |
| P3 | Which alpha `p` near water? | 3: (a) `texturemap.inc:463-472` gate via X28 §3.2; (b) shore tile ids via X28 §3.3 + F05 §3; (c) `DAT_008f5d00` pair LUT via `terrain_donor_mesh.gd:690-694` + `terrain_donor_shader.gdshader:217-229` + DEC_U_alpha_pass_quad §6 + PORT1TO1 §3.5 | **Accepted as RULE [O]/[D]**; per-cell value stays [U] (needs runtime mask+variant). |
| P4 | `alpha.bmp` / `alphavert.bmp` data feeding `p` | 2: (a) F06-E7/E9/E10 + `terrain_donor_shader.gdshader:70-73` + mesh consts `DONOR_ALPHA_ROWS/COLS/TILE_SIZE/W_PX/H_PX`; (b) `reftilealpha.mat:31,139,248` enum-1 selection + `tiaAlphaFromIntensity=1` | **Accepted**: geometry + selection [O]; byte arithmetic [U] (DEC_U §3.3 probe). |
| P5 | GL blend/alpha-test state per `BlendingMode` | 2: (a) re-read DEC_U_alpha_pass_quad §4.1-4.2 raw bytes/VAs; (b) capability table `0x8fb0dc` + factor table `0x8fb1c4/0x8fb1c8` + `hf.pvl.smx3.frag:13-14,50` | **Accepted [O]**: 6-case table closed; case 1 = ENABLE+ENABLE, no `glAlphaFunc`. |
| P6 | `tiaAlphaFromIntensity` → alpha feed | 2: (a) enum tables `ev_5b7d6bb8…`/`ev_c8049f68…` + `reftilealpha.mat:31,139,248`; (b) fragment consumers `hf.pvl.smx3.frag:50` vs `water.dev.frag:244-245` | **Accepted**: selection + feed topology [O]/[D]; arithmetic [U]. |
| P7 | Port change list without editing | 1: line-anchored read of `terrain_donor_mesh.gd` consts/telemetry + `terrain_donor_shader.gdshader` uniforms/fragment | **Accepted**: §7 lists exact `path:line` edits as proposals only; nothing written outside this report. |

Failed/limitation passes retained: no new `native_*` disassembly was run by this worker (by charter); static closure therefore rests on re-cited pinned evidence, and every residual is given an authorised-trace probe with a zero-mismatch termination condition (§6), never a guessed value.

---

## 2. Evidence register

### 2.1 Re-cited pinned donor evidence (from prior passes, `t_87f0f3c130b0`)

| Evidence id | Operation (prior pass) | Establishes (reused here) |
|---|---|---|
| `ev_5b7d6bb88066e28d4eba9215c91fafba3fdf8e939e726d1cd8e86c2019a` | `native_bytes_show 0x4e6d80`, 384 B (DEC_U §2) | RTTI `TOSWTextureImageAlpha`: 9 names, order pinned; `tiaAlphaFromIntensity` = **1** |
| `ev_c8049f689a2ff7b7f459504f1dca326bdcf7363966b2d8f1bbfdc9585` | `native_bytes_show 0x4e9280`, 384 B (DEC_U §2) | `ffffffff`-separated value table; same order → index mapping [O] |
| `ev_f438caefcb3920646e6c17e780ea77f99a580a38962604235c54a9cac843d0ce` | `native_bytes_show 0x4e6e20`, 96 B (DEC_U §2) | type data: `tkEnumeration`, max value **8**, pointer `0x4e6e24` |
| `ev_3c3c92b18c10c8fb880ec99b616cbc7f1392aa3661a07eec9c24c7bbc94ee1`, `ev_3909e3be9bdff29e82bdf2275cc5f455f06ebd64440d28f6d7bfa6adce77d7` | `native_xrefs_list` both string copies (DEC_U §2) | **0 static xrefs** — RTTI-name-only strings |
| `ev_96785ecceb0797c5196491b357e80c55a6fbad2ac5d178f16599fc0bf38739` | `native_function_disassemble 0x88f0f0`, 33 insns (DEC_U §2) | cached **enable** wrapper (`glEnable@thunk 0x4afb8c`) |
| `ev_1c986c730c2e3ce56a253994ccfb4de1f06da04bf91c7ed8f4aec8e3b4689824815` | `native_function_disassemble 0x88f148`, 33 insns (DEC_U §2) | cached **disable** wrapper (`glDisable@thunk 0x4afb6c`) |
| `ev_27eae37720f7f09bd487732270af4754c33d68bdef8959df834eaae05617c` | `native_bytes_show 0x8fb0dc`, 256 B (DEC_U §2) | capability table: `[0]=0x0bc0`, `[2]=0x0be2` |
| `ev_ca4650205cdf4ac3e8f076cba326f7b6e1fe28b5a6d28b5e06bcef`, `ev_01b5af2301a40f94f3ec09762c2362303e668c88288cd799ed916d5696a530` | `native_data_show 0x8fb0dc/0x8fb0e4` as u32 (DEC_U §2) | `[0]=3008=0x0BC0=GL_ALPHA_TEST`; `[2]=3042=0x0BE2=GL_BLEND` |
| `ev_c6b5ab46f70762cbf2274a9f42811ce6c00629dfe47c3d34c6b78e5eda98cf16` | `native_function_disassemble 0x4ef810`, 224 insns (DEC_U §2) | six `BlendingMode` case blocks incl. `0x4ef97a-0x4ef99a`, `0x4ef9c1-0x4ef9e9`, `0x4ef9f0` |
| `ev_8abea4014b499704b471a31daf7818556d46e543cccd8cdcc551c825922b9ec` | `native_function_disassemble 0x818920`, 1650 insns (DEC_U §2) | `0x50`-record consumer field offsets; `glEndList; ret` |
| `ev_6f767eede169f5e751f3e679b87a7f9a051eed0af1dbeef16d7755` | Deep `FUN_00812b4c` (DEC_U §2) | producer `0x48` record, UVs at `+5+corner*8` |
| `ev_8ed2a80907087fdcae0827b6762cf5dab2be63c64d7230ca5b5609a60c4ff`, `ev_696bc518d0ab6b3b28c3d5997f93c734e5d5230ca5bcd2153cd30417` | Deep `FUN_0081831c` / `FUN_00818428` (DEC_U §2) | single-UV vs two-UV emitters, `glColor4fv` |
| `ev_16a55d5469092dc3a559478db683fcb8481d4f6c2a3da5732b10f2843c581` | Deep `FUN_00854054` (PORT1TO1 §2) | 30-key binder; `hmapTex` gated on height object (water path, not terrain) |
| `ev_116683896d284b4ecbd4f6a8a73a6afc80055399c171ae42e0854d46fceaa365` | `native_bytes_show(0x8537e0,512)` (PORT1TO1 §2) | 30 `wst*` + 30 plain uniform key strings (water path) |

### 2.2 Fresh read-only port evidence (this pass, no donor target needed)

| File:line | What it establishes |
|---|---|
| `variant3d/config.json:33-36`, `variant3d/config_donor_capture.json:34-37` | port preserves `water.alpha_confine=true`, `water.shore_prox=false` (user mods preserve values — cited requirement) |
| `variant3d/scripts/config.gd:66-67,456-460` | defaults + getters `feature_water_alpha_confine()` / `feature_water_shore_prox()`; comments label confine "donor water-cell alpha gate kept" and prox "inert port-art multiplier removed" — **port labels, not donor citations** |
| `variant3d/scripts/water3d.gd:734-739,1002-1004` | both flags read into `cfg_alpha_confine/cfg_shore_prox` and exported as telemetry (`water_alpha_confine_config`, `shore_prox_config` + `"REMOVED (PORT ART…)"`); no terrain-mesh use |
| `variant3d/shaders/water3d.gdshader:533` | `TRN-WATER REMOVED the former shore_prox` in-shader comment |
| `variant3d/tests/t_terrain_shore.gd:94,101,110,270,600,643,926-935` + `tests/results/t_terrain_shore.json:112-113,149,161,192,278` | pre-fix checks: `no_port_art_shore_prox` (shader must NOT contain `shore_prox`), `water_alpha_confined_to_cells`; result file records `shader_has_shore_prox:true` pre-fix and `REMOVED — INERT (=1)` post-note |
| `variant3d/scripts/terrain_donor_mesh.gd:88-99,111-124,139-157,1586-1589,1846-1850,2068,2177,2183` | water/shore level consts; cap indices; `0x48/0x50/+0x0b` map; RGB/alpha LUTs+insets; per-surface `base_full_opacity/alpha_test_enabled=false/ref=-1.0/face_alpha_enabled=false`; `_alpha_index()`; `alphanull_ids=[86,110,123]` |
| `variant3d/shaders/terrain_donor_shader.gdshader:38-49,70-104,217-229,294-326` | blend contract; `alpha.bmp 512×256 8×4` / `alphavert.bmp 1024×512` samplers; `alpha_test_enabled=false/ref=-1.0` off-discard; `alpha_index()` LUT; `ALPHA=a` crossfade, `a=1.0` on `base_pass&&base_full_opacity`, `a=0.0` on alphanull, else `texture(alpha_atlas,UV2).a` |

---

## 3. Shore alpha confinement / proximity — static finding [U], never a donor constant

### 3.1 `alpha_confine=true` [U — port-only gate, no donor comparator]

- The key exists in both `variant3d/config.json:35` and `variant3d/config_donor_capture.json:36` as `true`. The task states user mods preserve these values; the file reads confirm byte-presence, nothing more.
- Consumers: `config.gd:66` default + `config.gd:456-457` getter; `water3d.gd:734,738,1003-1004` reads it into `cfg_alpha_confine` and reports `water_alpha_confine_config` telemetry. **Zero** references exist in `terrain_donor_mesh.gd` or `terrain_donor_shader.gdshader` (P1 grep: the only 87 hits are config/getter/water3d/test/shader-`.bak` files).
- Donor side: no `glAlphaFunc` threshold, no `water_cell`/`shore_prox`-style gate, no `alpha_confine` string, and no water-cell clamp exists in any recovered donor fragment: shipped `water.dev.frag` gates water by `if (height > level) { fragColor = vec4(0.0); }` with `ALPHA=coastfade2` (PORT1TO1 §5.1); terrain `hf.pvl.smx3.frag:50` writes `color.a=texUnit1.a` with no cell test (X17 §3.2); terrain `bmTransparency` case issues no `glAlphaFunc` (DEC_U §4 / §4 below). The `config.gd:66` comment "donor water-cell alpha gate kept" is therefore a **[I] port label**, not an `[O]` donor citation.
- **Rule for the port:** keep `alpha_confine` as a named, explicitly-labelled runtime parameter with **no hidden donor default**. It must never be folded into the terrain shader as a threshold, and its value `true` must never be cited as donor truth. Its only legitimate settled effect today is the water-side test `water_alpha_confined_to_cells` (`t_terrain_shore.gd:101,600,643`).

### 3.2 `shore_prox=false` [O-port REMOVED; donor [U] = does not exist]

- Both configs carry `false` (`config.json:36`, `config_donor_capture.json:37`).
- Port unanimously labels it removed art: `water3d.gdshader:533` ("REMOVED the former `shore_prox`"), `water3d.gd:1002` (`"REMOVED (PORT ART, RV-TRN-03 §5.2); absent from donor fragment"`), `config.gd:67` ("inert port-art multiplier removed"), `t_terrain_shore.gd:926-935` (`no_port_art_shore_prox` asserts the shipped shader does NOT contain it; pre-fix `shader_has_shore_prox:true` in `tests/results/t_terrain_shore.json:192`).
- Donor side: the shore gate is `mask.b>0 ∧ (h<-0.25 ∨ h<-0.1)` with `len>0.01` (`texturemap.inc:441-442,463-472`, X28 §3.2) — height + mask only, no proximity radius or falloff weight. The donor water fragment's only shore-distance terms are `coastfade=clamp((level-height)/0.57,0,1)` and `coastfade2=clamp((level-height)/1.07,0,1)` (PORT1TO1 §5.1), which are **water** alpha/foam terms, not terrain-mask multipliers.
- **Rule for the port:** keep `shore_prox=false` inert. Never reintroduce a `shore_prox * foam` multiplier into either shader; `water.dev.frag:227` verbatim has none.

---

## 4. Which alpha patch indices are used near water — rule [O]/[D], value [U]

### 4.1 Shore tile ids near water [O]

From X28 §3.3 (verbatim `texturemap.inc:503-511`, F05 §3 ids): the only live shore assignments are `sandsea1=93`, `sandsea5=97`, `sandsea6=98`. Sector → tile: `bB/bT→sandsea1`, `bLB/bRT→sandsea5`, `bR/bRB/bL/bLT→sandsea6`. Winter keeps the same numeric id. `sandsea2/3/4` survive only in smoothing lists (X28 §3.3 [D]). The current port's `WATER_SENTINEL=255` (`terrain_donor_mesh.gd:96`) is explicitly `PORT ONLY, not a donor tile id`.

### 4.2 Alpha patch rule [O]/[D] — no single "shore patch" exists

The overlay alpha selector is byte-proven on both sides of the port:

- Donor: `DAT_008f5d00` 16 low bytes + high=`low+16` on `variant&1` (`ev_8d1f6535…`, PORT1TO1 §3.5; DEC_U §6.2 `FUN_00812ccc` writes alpha UVs at producer `+0x25..+0x44` with `rot=2`, V-flip, insets `0.1/0.2` only for mask 0).
- Port (exact copy, no invention): `terrain_donor_mesh.gd:138-141,145-147,690-694` (`DONOR_ALPHA_PAIR_LO=[0,2,1,3,8,10,9,11,4,6,5,7,12,14,13,15]`, `+16` on `variant&1`, insets `0.1/0.2` with `ALPHA_DOUBLE_ROT=2/MIRROR=false/VFLIP=true`) and `terrain_donor_shader.gdshader:217-229` (`alpha_index()` verbatim).
- **Near-water consequence [D]:** a shore cell is an overlay quad (`layer_index>0`) whose `COLOR.b = p = ALPHA_index(mask,variant)` where `mask` is the 4-corner weight sum (`DONOR_CORNER_WEIGHTS=[8,2,4,1]`, `terrain_donor_mesh.gd:128,655-663`, raw compares `0x813125-0x813145` `ev_58d7418c…`) and `variant` is the per-cell image-state byte (`variant&1` selects the high half). Hence near-water `p` ranges over the 32-entry set `{lo(mask), lo(mask)+16}`, `lo` from the 16-entry table above, for whichever `mask∈{1..14}` the shoreline geometry produces; the base quad under it always carries `p∈{0,16}` (both authored constant 255, F06-E10; port forces `a=1.0`, `terrain_donor_shader.gdshader:307-308`).
- **What is NOT claimed:** without the runtime `(mask, variant&1)` pair for a specific cell, naming e.g. "`p=6` at the shoreline" would be invention. The three `alphanull` ids (`86/110/123`, `terrain_donor_mesh.gd:2183`, shader `:310`) force `a=0.0` and are the only id-driven alpha override; they are not shore tiles.

### 4.3 `alpha.bmp` / `alphavert.bmp` data [O geometry; bytes [U]]

- `alpha.bmp`: 512×256 8-bpp patch atlas, 8×4 grid of 64² patches (`terrain_donor_mesh.gd:140-144`: `ROWS=8/COLS=4/TILE=64/W=512/H=256`; shader `:70-71` + F06-E7/E9/E10). Selected by `reftilealpha.mat:31,139,248` with `ImageAlpha=1` = `tiaAlphaFromIntensity` (PORT1TO1 §7 chain, DEC_U §3.1).
- `alphavert.bmp`: 1024×512 (shader `:72-73`, F06-E11/E12); sampled only on the unresolved face-refkey path (`face_alpha_enabled && face_mode!=0`, shader `:297-303`; mesh `:1589` forces `false`, U-8).
- Authored sentinels [O]: patch `0`/`16` constant 255; `p=0` and `p=16` → 255, `p=15` and `p=31` → 0 (DEC_U §3.3 step 5; F06-E10; PORT1TO1 §5.1). The full 256-entry `idx→A` LUT remains [U] pending the §6 U-SA3 byte dump.

---

## 5. GL_ALPHA_FUNC comparator/ref per blending mode [O] + intensity→alpha feed

### 5.1 Six-case table (byte-proven, `ev_c6b5ab46…`, DEC_U_alpha_pass_quad §4.2)

Capability indices read table `0x8fb0dc` (`ev_27eae377…`, typed `ev_ca465020…`/`ev_01b5af23…`): cap 0 = `3008/0x0BC0/GL_ALPHA_TEST`, cap 2 = `3042/0x0BE2/GL_BLEND`. Wrappers: `sub_88f0f0` = cached enable, `sub_88f148` = cached disable. Factor table `0x8fb1c4/0x8fb1c8` in D08 §3.5 / X17 §3.1.

| Case | Enum | VA block | Exact ops in order [O] | Comparator / ref |
|---|---|---|---|---|
| 0 | `bmOpaque` | `0x4ef961` | `glDisable(GL_BLEND)` (`0x4ef966` via `sub_88f148`); `glDisable(GL_ALPHA_TEST)` (`0x4ef970`) | none (both disabled) |
| **1** | **`bmTransparency` (terrain)** | **`0x4ef97a`** | **`glEnable(GL_BLEND)`** (`0x4ef97f`, `dl=2`); **`glEnable(GL_ALPHA_TEST)`** (`0x4ef989`, `edx=0`); **`glBlendFunc(0x302,0x303)` = `(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)`** (`0x4ef995`) | **NO `glAlphaFunc` in this case** — comparator/ref is NOT reset; it is the GL default (`GL_ALWAYS/0`) or whatever a prior case-3/4 call leaked [U U-6b] |
| 2 | `bmAdditive` | `0x4ef99f` | `glEnable(GL_BLEND)`; `glEnable(GL_ALPHA_TEST)`; `glBlendFunc(0x302,0x301)` = `(SRC_ALPHA, ONE)` | none issued (same leak exposure as case 1) |
| 3 | `bmAlphaTest50` | `0x4ef9c1` | `glDisable(GL_BLEND)`; `glDisable(GL_ALPHA_TEST)`; **`glEnable(GL_ALPHA_TEST)`**; **`glAlphaFunc(table_alpha[7]=0x206=GL_GEQUAL, 0.5f)`** (`0x4ef9e9`) | **`GL_GEQUAL / 0.5`** |
| 4 | `bmAlphaTest100` | `0x4ef9f0` | `glDisable(GL_BLEND)`; `glDisable(GL_ALPHA_TEST)`; `glEnable(GL_ALPHA_TEST)`; `glAlphaFunc(GL_GEQUAL, 1.0f)` | **`GL_GEQUAL / 1.0`** |
| 5 | `bmModulate` | `0x4efa1f` | `glEnable(GL_BLEND)`; `glEnable(GL_ALPHA_TEST)`; `glBlendFunc(0x304,0)` = `(DST_COLOR, ZERO)` | none issued |

Port consequence (already in-shader, keep): `render_mode blend_mix` reproduces the case-1 factor pair with `GL_FUNC_ADD` (X17 §3.2); the optional `alpha_test_enabled/alpha_test_ref` discard stays **OFF** (`false/-1.0`, shader `:94-101`, mesh `:1587-1588`) because case 1 has no comparator to reproduce; `rgb *= a` is forbidden (X17 §3.2, shader `:320-322`).

### 5.2 Intensity→alpha mapping [U arithmetic; feed topology [O]/[D]]

- `tiaAlphaFromIntensity` is enum value **1** [O] (§2.1). Its byte arithmetic (identity vs complement vs sqrt vs custom 256-LUT) is **[U]** (DEC_U §3.2: 0 static xrefs, candidates `0x4ec07c/0x4ec0a0` refuted as `ImageBrightness`, function discovery capped at 6M insns). Identity `A=intensity` is **[I] only** (consistent with F06-E8 `V(idx)=max(0,idx-3)` but byte-unproven and semantically colliding with `tiaLuminance`).
- **Feed [O]/[D]:** the terrain fragment does NOT compute alpha from intensity. `hf.pvl.smx3.frag:13-14,50` (X17 §3.2): `color.rgb=texUnit0.rgb`, `color.a=texUnit1.a` — the uploaded `alpha.bmp` texel **is** the alpha. The port reproduces exactly this: `a=texture(alpha_atlas,UV2).a` (shader `:311`), `ALPHA=a` (`:325`), no luma on the alpha path.
- The only donor `intensity` variable lives in the **water** fragment: `intensity = r*.2126+g*.7152+b*.0722; watercolor=mix(watercolor*intensity, watercolor2, smoothstep(0,1,coastfade2))` (PORT1TO1 §5.1 verbatim). Its alpha is `resalpha=coastfade2=clamp((level-height)/1.07,0,1)` — depth-driven, never `intensity`-driven [D]. Do not wire water `intensity` into terrain alpha.

---

## 6. `[U]` register — exact settling experiment per field (fixed-camera shore frame + GL alpha byte-dump, zero-mismatch termination)

General harness (all three): authorised debugger/GL-trace worker only (this charter forbids execution). Fixed camera: top-down orthographic-equivalent capture of a generated skirmish shore cell block containing `sandsea1/5/6` + open water, same map/camera on donor and port; ROI = the 2×2 water-field quad at `Y=-0.5` overlapping the `h∈[-0.25,-0.1)` band. Termination in every case: **byte-exact zero-mismatch** reproduction of the dumped bytes/table, including the four authored sentinels (`p=0,16→255`; `p=15,31→0`).

| # | `[U]` field | What is known | Exact settling experiment (no approximation) |
|---|---|---|---|
| U-SA1 | Shore confine rule/threshold behind `alpha_confine=true` | Port key + getter + water telemetry only (§3.1); no donor text/VA | (a) Fixed-camera shore frame on donor with a `glBlendFunc/glAlphaFunc/glEnable(GL_ALPHA_TEST)` trace filtered on the heightfield display-list id (`FUN_0081a8e4` record `+8`, DEC_U §5.2); record src/dst factors + enable bits + any `glAlphaFunc` comparator/ref actually in effect at the terrain draw. (b) Dump the `alpha_atlas` upload (`glTexImage2D`, `format==GL_ALPHA 0x1906`, `512×256`) and compare the shoreline-ROI alpha bytes against the port's `texture(alpha_atlas,UV2).a` bytes. **Terminate** when the port reproduces the donor ROI alpha bytes with zero mismatches with `alpha_confine` removed/kept as a labelled no-op — i.e. prove no hidden confine threshold is needed. Never invent a depth/radius cutoff. |
| U-SA2 | Shore proximity radius/weight behind `shore_prox=false` | Port REMOVED art [O-port] (§3.2); donor gate is height+mask only | (a) Same fixed-camera shore frame; (b) break on the terrain `FUN_00818428` two-UV emitter and dump per-corner `(Q+0x30..+0x4f)` alpha UVs + `texture(alpha_atlas,UV2).a` for shoreline quads; (c) assert no additional distance-from-water multiplier is applied between the UV fetch and `glBlendFunc`. **Terminate** when the port's `ALPHA=a` bytes match the donor `texUnit1.a` bytes with zero mismatches at `shore_prox=false`. Never reintroduce a `prox * foam` term. |
| U-SA3 | `tiaAlphaFromIntensity` byte arithmetic (enum value 1) | Enum + selection [O]; arithmetic [U] (§5.2) | DEC_U_alpha_pass_quad §3.3 probe verbatim: after `reftilealpha.mat` parse assert `ImageAlpha==1`; break on `glTexImage2D` with `format==GL_ALPHA` and `512×256` (`alpha.bmp`) / `1024×512` (`alphavert.bmp`); dump `pixels` (131,072 B / 524,288 B) before consumption; compare against `V(idx)=max(0,idx-3)`, `255-V`, `round(255·sqrt(V/255))`, else emit the 256-entry `idx→A` LUT. **Terminate** on a closed form or byte-exact 256-entry table with zero mismatches on BOTH textures + four sentinels fit. No substitute value baked before step 5. |
| U-SA4 | Per-cell near-water patch index `p` (mask+variant→p instance) | Rule [O]/[D] (§4.2); instance [U] | (a) Fixed-camera shore frame; break on `FUN_00812ccc`/`FUN_00812b4c` producer for a shoreline cell and record `(mask&0xff, variant&1)`; (b) read the emitted `0x50`-record `+0x30..+0x4f` alpha UVs and the `alpha.bmp` texel at that UV; (c) compare against the port `COLOR.b=_alpha_index(mask,variant)` + `texture(alpha_atlas,UV2).a` for the same cell. **Terminate** when every shoreline quad in the ROI matches with zero mismatches. Never assert a fixed "shore p" (e.g. `p=6`) — the table has 32 entries and the shoreline produces several masks. |
| U-SA5 | `GL_ALPHA_TEST` comparator/ref actually in effect at the terrain draw (U-6b leak) | Case-1 has none [O]; leak [U] (§5.1) | GL trace of `glAlphaFunc` vs `sub_4ef810` case-1 order in a live frame containing a shore draw: record the last `glAlphaFunc` (mode/ref) preceding the heightfield `glCallList`, and whether any case-3/4 draw intervenes. **Terminate** when the observed compare func/ref at the terrain draw is recorded; only then may a labelled `alpha_test_ref` be set — never `0.5`/`1.0` by default. |
| U-SA6 | `alphavert.bmp` face-projection use at the shoreline (cliff faces) | Mesh forces `face_alpha_enabled=false` [O-port] (U-8); projection [U] | Fixed-camera cliff-face frame at a `rock1/3/4/7/8` shore-adjacent cell (X28 §3.4 ids); trace `glTexImage2D` for `1024×512` + `glEyePlane/texgen` state at the face draw. **Terminate** when the port either reproduces the face alpha bytes with zero mismatches or keeps the path OFF with a labelled residual — never a `0.125`-scale guess beyond the cited `reftile.mat:122-167` slot. |

---

## 7. Port change list — `terrain_donor_mesh.gd` / `terrain_donor_shader.gdshader` (proposals ONLY; nothing edited)

Conventions: `path:line` anchors are the current read-only line numbers; each item states the exact old text and the exact new text. **Do not apply** without the §6 probe for that row terminating at zero mismatches. No parity claim follows from any row.

1. `variant3d/shaders/terrain_donor_shader.gdshader:92-93` — base-pass comment cites authored-255 [O]; **no change** (keep `base_full_opacity=true` forcing `a=1.0` at `:307-308`). Rationale: `p∈{0,16}` constant-255 is the only byte-proven shore-adjacent alpha fact (F06-E10).
2. `variant3d/shaders/terrain_donor_shader.gdshader:94-100` — `alpha_test_enabled=false`, `alpha_test_ref=-1.0` + NO-comparator comment; **no change** until U-SA5 terminates. If U-SA5 observes a leaked `GL_GEQUAL/0.5|1.0` at the terrain draw, add a labelled uniform default (e.g. `alpha_test_ref=0.5` with a `// [U-SA5] LEAK OBSERVED <trace id>` comment) — never `0.5`/`1.0` by default.
3. `variant3d/shaders/terrain_donor_shader.gdshader:304-312` — overlay fetch `a=texture(alpha_atlas,UV2).a` + `is_alphanull ? 0.0`; **no change** until U-SA3/U-SA4 terminate. If U-SA3 yields a non-identity 256-LUT, insert it as a labelled `const float TIA_LUT[256]` + `a=TIA_LUT[idx]` fetch **alongside** (not replacing) the texture fetch, gated by a new `uniform bool tia_lut_enabled=false`, with the trace/LUT id in comments. Never fold water `intensity` (luma) into this branch.
4. `variant3d/scripts/terrain_donor_mesh.gd:1586-1589` — per-surface dict (`base_full_opacity:true`, `alpha_test_enabled:false`, `alpha_test_ref:-1.0`, `face_alpha_enabled:false`); **no change** (mirrors the shader's settled state; confine/prox must NOT be added here — see 6).
5. `variant3d/scripts/terrain_donor_mesh.gd:690-694` + `variant3d/shaders/terrain_donor_shader.gdshader:217-229` — `_alpha_index()` / `alpha_index()` pair LUT; **no change** (byte-exact `DAT_008f5d00` copy). If U-SA4 terminates with a conflicting observed `(mask,variant)→p` instance, file it as a new `[U-SA4]` residual with the trace bytes — do not hand-edit the LUT.
6. **Do NOT add** `alpha_confine` / `shore_prox` uniforms, thresholds, radius constants, `water_cell` gates, `fract(world*…)` proximity weights, or `rgb *= a` to either file. Both keys stay where they are (`config.gd:66-67,456-460` getters; `water3d.gd:734-739,1002-1004` telemetry; `water3d.gdshader:533` removal note). Any future shore-confinement behaviour must arrive as a new named uniform with an `[U-SA1/U-SA2]` label and a zero-mismatch §6 trace — never as a silent numeric default.
7. **Do NOT add** `discard`, `alpha_scissor`, `step(a,…)`, or `clamp(a,…)` substitutes for the terrain case-1 draw (DEC_U §4.3 prohibition; §5.1 table). The only permitted discard is the existing `alpha_test_enabled && a<ref` branch (`shader:315-317`), which stays OFF.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary was executed, no donor asset copied, no GPU frame captured, no port capture compared. All shore-alpha readings above are structural `[O]/[D]` or explicitly labelled `[U]`/`[I]`.
- **No approximation substituted.** No confine threshold, proximity radius/weight, fixed shore patch index, `glAlphaFunc` comparator/ref for case 1, or `tiaAlphaFromIntensity` formula is presented as donor truth. Every residual names its authorised-trace instrument and its zero-mismatch termination condition (§6).
- **Read-only compliance.** Exactly one file written (`docs/terrain_swarm_2026-11-26/reports/DEC_U_shore_alpha.md`). No code/asset/config/Godot/git change. Donor target (where cited) remained pinned `t_87f0f3c130b0`; no donor binary was executed and `t_68474ddde43f` was never opened.

*End of DEC-U-SHORE-ALPHA report.*
