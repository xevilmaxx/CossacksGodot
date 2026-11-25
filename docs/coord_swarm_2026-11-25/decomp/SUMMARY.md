---
title: DONOR DECOMPILATION — consolidated findings (2026-11-25)
area: donor decompilation
owner: COORD (aggregates DEC-01…DEC-08, RV re-verifications + Batch I late deep dives)
updated: 2026-11-25
refreshed_with: late deep dives (Batch I) — DALPHA, DPATTERN, DFX, DANIM, DBIND, DENV, DFORM, DUNIT, DAUDIO, DMAPGEN, DBUILD, LIGHT-02; DSEASON-01 / DONAVAL-01 not landed
corrections_authority: ../CORRECTIONS.md (57 rows) — authoritative; §9 here is the decomp-lane convenience copy
status: lane closed — summary refreshed 2026-11-25 with the late deep dives
---

# 🔬 Donor decompilation — consolidated findings

**Lane closed.** Eight micro-workers documented the installed donor at
`C:\Games\Cossacks 3` read-only (Python `bytes`/latin-1, Craft Anything read tools, short
hex excerpts). No donor binary was executed or copied into the repo. This file consolidates
their results and the cross-lane re-verifications that amended them. Full detail, claim tables
and evidence ids live in the eight `DEC_0x_*.md` records; `EVIDENCE_INDEX.md` indexes the ids.

**Refresh (2026-11-25).** After the lane was declared closed, twelve late deep dives landed and
reversed several earlier claims. §13 records their donor truths with report paths and labels;
§9 and §12 are updated accordingly. The **authoritative** corrections index is
`../CORRECTIONS.md` (57 rows) — where this file and that index differ, that index wins; never
cite a superseded half-truth from here. Every claim below stays labelled
`observed`/`derived`/`inferred`/`UNVERIFIED`, and **no donor visual-parity claim is made**.

## 1. Donor identity and runtime — DEC-01

- Every `.cdx` is byte-identical to its `.exe`/`.dll` twin **except 3 bytes at file offset
  `0x128`** (PE `AddressOfEntryPoint`): the `.exe` entry stays in `CODE`, the `.cdx` entry is
  redirected into the pre-existing ~146.8 KB `.bind` section at a uniform `+0x310`.
- **Correction:** `cossacks.exe` entry VA `0x8f1a08` (RVA `0x4f1a08`) is in `CODE`, **not**
  `.bind` as `DECOMP_01`/`DA_PE` claimed. Only the `.cdx` entry is in `.bind`.
- `codex.dll` is internally `WUS` (sections `WUS0`/`WUS1`, export DLL name `wus.dll`);
  `steam_api.dll` imports a DLL literally named `CODEX`; `steam_emu.ini` has
  `AppId=333420`, `UserName=CODEX`, `[Crack]`.
- Entropy is localized to `.bind` (7.965) and `WUS1` (7.905) vs `CODE` (6.609). Packed
  **content is UNVERIFIED** — `core_packed_files_list` refuses both files as "not a container".
- Compiler proof: `Borland\C++Builder` (`editor.exe:0x3205ae`), `Delphi%.8X`
  (`cossacks.exe:0x4e379c`), Delphi timestamp `0x2A425E19`. 112 curated `X*` RTTI names,
  48 OSW units, **0 code xrefs** → a subsystem name map, not a class tree. Game-EXE "Rich"
  hits are the substring in "Pierre le Riche", not MSVC headers.

## 2. Scripts — DEC-02

- **All 222 donor script files** (4,373,442 B) enumerated with size, line count, encoding,
  syntax container and purpose. **19 files are ASCII code with CP1251 Russian comments**, not
  UTF-8 — a decoding correction for any future text pass.
- 16 deep records with `path:line` pseudocode: constant/type bible, bootstrap load order,
  formation loader, selection/cursor priority, camera, damage formula, squad disband/hold,
  costs/production, income/upkeep, market, famine/rebellion, 3-layer AI, terrain/decor
  generation, season, FX/particles, sound, serialisation.
- **Formation bonuses are consumed** (`init.script:38-78` → `player.script:809-812` →
  `miscext2.script:347-354,425-431`) — closes DB-01. Port imports all 149 tuples
  (verified by DEC-03).
- **No numeric morale exists.** Disband is `count < 0.25 × basecount`; shooter retreat is a
  move-order mode. The port's famine HP drain and morale constants are **invented**. Donor
  famine is a difficulty-scaled death roll.
- Market is mean-reverting with exact bands and four update equations
  (`lib/res.script:178-250,272-344`). Recruit click modifiers are implemented in the port
  (P6's "gap" section is stale). `-5` produces **five infinite orders**.
- `hotkeys.cfg` has **no patrol binding** (`Q` = viewcollision, `P` = build port) — RB G-12's
  premise is unverified.
- Camera key names join to their consumer: `lib/control.script:581-589` loads
  `data\cameras\camera.cfg` directly (SphereHeight 58, DynFogDepth False, all angles −32).

## 3. Config truth — DEC-03

- **77** `.cfg`/`.ini` files inventoried (74 ASCII, 3 with Cyrillic bytes, 2 zero-byte stubs).
- `hotkeys.cfg`: **243 lines but only 55 bindings** (52 keyed, 3 empty) — the prior "243
  bindings" claim was wrong. Full binding table recorded.
- `formations.cfg`: **149 IDs, 137 symmetric, 46 non-zero bonuses** (not 43). Exact tuples
  and masks, including outliers `TRI_OLD(-10,9,95,-19)`, `PRUS_OLD(5,-5,-27,80)`.
- `envscales.cfg`: **122 objects / 26 groups**, with **three** jitter bands (1/1, 0.95–1.05,
  0.85–1.15) — prior "all 0.85–1.15" was wrong. Duplicate `horseradish.1` noted.
- `light.cfg`, `env.cfg`, camera configs, skydome, clouds, time, stars, particles: exact
  fog/light/sky constants with line citations.
- **Port comparison:** formations fully imported (149/149, diff 0); hotkeys partially wired
  (42 binds vs 52 keyed, 3 wrong mappings, all `Repeat`/`AlternativeKey`/`Up` flags missing);
  env scales a 3-class approximation; **light/sky colours NOT imported** — highest visual
  fidelity gap (port has darker sky and white sun).

## 4. Animation / audio formats — DEC-04

- `.oss`: no magic/version; 24-byte `<6i k,fps,b,v,fc,t>` header, tight LE sections, weight
  lists summed over all `v` lists; **335/335 exact size closure, zero slack**, fps=30.
  No parent table or bone strings confirmed three ways.
- **Correction to DEC-04 (which had itself "corrected" DEEPDEC-06):**
  `../reports/DANIM_01_action_ranges.md` (DANIM-01, §6) refuted
  DEC-04's claim that frame 0 is not a bind pose. With two independent methods (sequential
  `read_oss` + quaternion check; bone-major offset-seek census of all 335 `.oss`), frame 0 is
  identity in **335/335** files (max |p|=1.09e−6 m, `peaukr` skin displacement at f0 1.52e−7 m),
  confirming DEEPDEC-06 F4/F5. DEC-04's Method C misread a bone-major track array as
  frame-major. Bone parents remain absent but pre-folded; flat-root sampled poses stay the
  defensible donor-derived path with the approximation label.
- `.osm`: `IDP2` v8, 17 int32, fixed 64-B `SkinBitMap` + 16-B `FRAME` header; **130/3,897**
  files have extra un-headered vertex frames.
- `.aaf`: `AAF` magic, CRLF, inclusive ranges, 246/246 parse, 1,434 rows all `morph`;
  durations `(last−first+1)/30`. ACL is an OSW dialect refkey chain; sid→ACL binding in
  `acl.lib` (153 refs).
- Audio: **325/325** Ogg Vorbis v0 stereo; the "327 paths vs 325 clips" discrepancy is two
  empty template `Path = ` lines. "733/733 verts" = OBJ `vt`/rendered-corner count, **not**
  donor skin vertices (`.oss` v=577).
- Six findings recorded in Craft Anything as `fnd_1..fnd_6`; 14 evidence ids in the report.

## 5. Terrain formats — DEC-05

- **New donor constant:** `dmscript.global:171` `gc_meters_to_tile = 2` (px/m 26.6666666,
  px/tile 53.3333333). Port `TILE_M=2.0` is therefore **donor-grounded** (DTRN-01 C6 corrected).
- `.map` contains a per-cell terrain grid: `TerrainMapBegin` → `<4i 320/384, 320/384, 4, flag>`
  then 102,400 (or 147,456) × **37-byte records** with four `1.0f` values and preset-like id
  bytes; verified in four maps, semantics still UNVERIFIED. Partial correction to "no donor
  tile-index file".
- `heightmapwaves0.tga` alpha is **255 for all 65,536 pixels** → cannot supply `hmapTex.w`.
  TGA masks are **RLE** (4,467/4,510), not uncompressed. Donor has no `terrain/heightmap/**`
  or `terrain/blocks/**` directories (port-side only).
- Full binary layouts for `terrainmesh*.osm`, DDS (DXT1/DXT5, no terrain normal/height),
  tile BMPs (quantised R→preset ids), alpha atlases, tile-id→texture table, **118 authored
  smoothing rules**, shore sector table and height formula.

## 6. Map / editor formats — DEC-06

- `.map`: flat, uncompressed, 7-bit-ASCII length-prefixed Delphi stream. Full RTTI-like schema
  (`TMapSettingsGen`, `TMapPlayer[8]`, `TScenarioTriggerCondition[8]`,
  `TScenarioTriggerAction[16]`, `TScenarioTrigger`) plus `gMap`/`gScenario` blobs and hexdumps.
  Height/tile/entity grids reconfirmed on 3 maps. 87-map survey: 320²×80, 384²×3, 512²×3,
  640²×1.
- `.aix`: all 65 files 7-bit ASCII CRLF; 30 base + 18 DLC mission sidecars;
  `scripts/editor.aix` is a 173-entry state→`.inc` registry. Objectives live in `.map`
  `gScenario` (D-12 deferred).
- `.cdx`: not a data format — five PE32 files byte-identical to twins except the 3-byte entry
  redirect at `0x128`. DA_PE's "6 PE files" refuted (19 found).
- Skirmish seed chain `GenerateMapRandKey` → `randkey0/randkey1` → three RNG setters →
  `GenerateMapNeededExtBorder`, with size/season/preset enums and reseeding points.
- Generator evidence: 8-sector shoreline rule (`sandsea1/5/6`, `rockN`), seasonal tile-id
  histograms, two-layer forests (tile + `env` trees), ring-based `mng/mni/mnc` mine placement.
- Corrections: DD "CLOSED grid" refuted; DECOMP-06's universal ±2.964 corrected (battle1 max
  +2.3712); DEEPDEC fixed 31-B records and "tile size 64" refuted.

## 7. Cameras / shaders — DEC-07 (amended by RV-CAM-01)

- 4 camera files and **109 shader FILES** (not 109 programs: 6 exact duplicate pairs, 20 bone
  files collapsing to 2 templates). Every camera key and shader family's uniforms/constants/
  samplers documented.
- Projection chain: perspective, focal 400, tilt −32°, dolly 20–58 m, yaw 0 toward −Z;
  bookmark `(h=49, back=78.42125)` gives `back = h·cot(32°)` to 0.006%. Closed-form ground↔screen
  formulas including horizon row `v_h = H/2 − f_px·tan(32°)`.
- **Two DEC-07 corrections were themselves refuted by RV-CAM-01:**
  - §8.1 "`.inc` scripts are commented-out": **wrong**. `[*] = ;` is a live `Code`-struct
    string-list encoding (5–7 envelope lines vs 32–898 payload lines); `menu.cfg`/`menu.aix`
    register the handlers. Real comments are `//` and `{ }`.
  - §8.3 "prior FOV arithmetic wrong": **wrong**. 17.27° is the 16:9 **vertical** FOV of a
    216 mm **horizontal** sensor at f=400; 5.15°/30.22° are the corresponding H-FOVs.
- Numeric donor FOV remains **CONFIRMED_UNVERIFIED** (no sensor key in 17,001 files; FOV API
  has no script call sites). Keep `FOV_DEG_ASSUMED=17.27` labelled PORT APPROX.
- Port gaps: shadow/fog disabled, neutral light/eye-plane uniforms, `screen_to_world()` flat
  Y=0 vs donor raycast, water omits `CalcTerrain`/LINEAR fog/real reflection, no post chain.

## 8. UI / strings — DEC-08

- Minimap = bottom-**RIGHT** 240×240 (`initminimap.inc:17,33`; 289-px right strip reserved),
  resolving the `[U]` in `RE_VISUAL.md` and DEEPDEC-08's "bottom-left" wording. Port still
  has 200 px bottom-left.
- Selection brush reconfirmed: `resource.lib:47` → `brushes/selection.cfg:2-14` = yellow
  `(1,1,0,1)`, 1 px, solid, `LineStep=1`; engine-driven (`menu.cfg:17-18`).
- `.lng` layout decoded: `u32 count` + (`u32 len` + `key=value` + `0x03`) records;
  `gui.lng:0x00`=460, first string `:0x08`; `en/gui.txt` 461 keys vs 460 compiled; English
  `misc` strings in `needloc/misc.txt`; `lang.loc` maps 11 languages to font codepages.
- 4×23 512² 8-bpp BMP fonts, 64×64 32-bpp `primitives.bmp`, 34 minimap atlas primitives with
  exact UVs, CUR hotspots at byte offsets. Rally = 3D game object (scale 0.0525, roll 45).
- Corrections: `hud3d_adapter.gd:57-62` half-map fix supersedes V717; stale `camera3d.gd:354`
  comment contradicts `:435-436`; `.inc` total is 313 (not 455).
- Port gaps: 3D selection rectangle not rendered, minimap 200 px bottom-left, no double-click
  jump, no locale layer, pop caps 200 vs donor 500–8000.

## 9. Corrections to prior docs — consolidated

**Authority:** `../CORRECTIONS.md` (57 rows) is the authoritative corrections index. The rows
below are the decomp-lane convenience copy; carry forward each row's caveat (`PARTIAL`,
`CONFIRMED_UNVERIFIED`, `CONFIRMED_INFEASIBLE`) and cite the authority row, not the old claim.

| Prior claim | Corrected by | Truth |
|---|---|---|
| `.cdx` entry in `.bind` for `.exe` too | DEC-01; DBIND-01 (`../reports/DBIND_01_wus_bind.md` §6 #5) | Only `.cdx`; `.exe` entry in `CODE` |
| `.bind` uniformly high entropy / stub unreadable | DBIND-01 §6 #1–#3, §8 | Three regions, shared 11,264-B plaintext x86 loader; only ~135 KB payload opaque; no container (three constants `CONFIRMED_INFEASIBLE`, §12) |
| "no FOV token in donor" | DSEL-02 / DEC-07 | API exists, runtime-derived; numeric FOV `CONFIRMED_INFEASIBLE` (DBIND-01 §5.2) |
| `.inc` scripts commented out | RV-SEL-01 / RV-CAM-01 | `[*]=;` = live code; `//` = real comment |
| DEC-07 FOV arithmetic correction | RV-CAM-01 | 17.27° = correct V-FOV; 5.15/30.22 = H-FOV |
| `TILE_M=2.0` is port-only | DEC-05; `../CORRECTIONS.md` #10 | Donor-grounded: `gc_meters_to_tile=2` (`dmscript.global:171`) |
| 243 hotkey bindings | DEC-03 | 55 bindings in 243 lines |
| 43 non-zero formations | DEC-03 | 46 |
| envscales all ±15% | DEC-03 | three bands (0, ±5%, ±15%) |
| DEC-04: frame 0 is NOT bind for multi-bone | `../reports/DANIM_01_action_ranges.md` §6; `../CORRECTIONS.md` #14/#51 | **DEC-04 refuted**: 335/335 frame-0 identity (max \|p\| 1.09e−6 m, `peaukr` skin f0 1.52e−7 m); DEEPDEC-06 F4/F5 confirmed; DEC-04's Method C misread bone-major as frame-major |
| "733/733 skin verts" | DEC-04 | OBJ `vt` count; `.oss` v=577 |
| `heightmapwaves0.tga` = `hmapTex` | DEC-05 / RV-TRN-03 | commented only, alpha all 255 |
| no donor tile-index file | DEC-05 / DEC-06; `../CORRECTIONS.md` #11 | `.map` `TerrainMapBegin` has 102,400 × 37-byte per-cell records; field semantics UNVERIFIED |
| donor has numeric morale | DEC-02; `../reports/DFORM_01_formations_morale.md` "Morale verdict"; `../CORRECTIONS.md` #22 | No numeric morale; human-only disband `count<0.25×base`, shooter retreat = move mode 2; port `MORALE_*` invented |
| donor patrol hotkey | DEC-02 | none (`Q`=viewcollision) |
| `FogMode=0` means donor fog is off | `../reports/DENV_01_environment.md` §2.10/§6 C4; `../CORRECTIONS.md` #28/#52 | **Ambiguous, not off**: donor `TFogMode` 0-based (`fmLinear=0`) → GL `GL_LINEAR`, scene fog `FogStart=390`/`FogEnd=490`; shader `fogMode` 1-based; `+1` bridge UNVERIFIED. Keep port fog off, do not assert "donor fog off" (`PARTIAL`) |
| DEC-03 sky `startcolor`=zenith, `stopcolor`=horizon | `../reports/DENV_01_environment.md` §6 C1; `../CORRECTIONS.md` #29 | Labels inverted only, values correct: `startangle=-5` = horizon (pale), `stopangle=90` = zenith (deep) |
| alpha masks are exact complementary pairs | `../reports/DALPHA_01_alpha_subrect.md` §5 #3/§7 #1; `../CORRECTIONS.md` #43 | Only 4 exact pairs, all constant 255 vs constant 0 sentinels; graded best MAD 9.77 with derived `(r,c)↔(3−r,3−c)` structure (`PARTIAL`) |
| whole-atlas `fract(v_st)` sampling is donor-shaped | DALPHA-01 §5 #1/§6; `../CORRECTIONS.md` #44 | Donor alpha is 8×4×64² patches; sub-rect geometry donor-grounded, tile→patch index `CONFIRMED_UNVERIFIED` (APPROX) |
| port map sizes match donor | `../reports/DMAPGEN_01_skirmish_options.md` §2.1/§5; `../CORRECTIONS.md` #54 | Donor 256/320/480/640 (`donewgame.inc:42-49`), seasons 0/2/3 with no selectable 1; port 240/320/400/480 diverges |
| selection sounds are positional unit sounds / order acks exist | `../reports/DAUDIO_01_sound_events.md` §6 #6/§8; `../CORRECTIONS.md` #55 | Interface-bank, **non-positional** `_sound_PlaySound` (`showunitcontrol.inc:1024-1027`); all `gc_snd_ind_order*` calls commented, constants undefined |
| relief height comes only from generator noise | `../reports/DPATTERN_01_relief_grids.md` §10; `../CORRECTIONS.md` #36/#56 | `.pattern` binaries embed `w×h` float32 grids; 26 bit-exact; mountain grids all-zero + `terrainmeshN` props, not taller bumps |
| 180 MB atlas untracked / LFS makes clones small | `../reports/ATLAS_01_transport.md`; `../CORRECTIONS.md` #53 | LFS pointer (134 B) **is** tracked, but ~180 MB split parts are ordinary Git blobs → clone size unchanged; pointer falls back to split |
| donor world is Z-up; config Z is elevation | `../reports/LIGHT_02_light_space.md` §5 #3/§8 | Donor world is **Y-up** (derived 4 ways): `light.cfg:27-29` Y=elevation, `default.cameras` `UpY=1`; `water.dev.vert:22` is water-local Z-up, not a world mapping. TERRAIN-DARK-FIX axis swap correct but PORT APPROX |

## 10. Cross-lane re-verifications (third/fourth passes)

`../reports/RV_SEL_01_selection_reverify.md` — `.inc` convention resolved; 0.005 m threshold;
yellow 1 px brush. `RV_CAM_01_fov_resolution.md` — FOV conflict resolved as UNVERIFIED.
`RV_TRN_01_texgen_mask_reverify.md` — 8×4×64 alpha patch grid empirically confirmed; eye
planes/blend passes UNVERIFIED; raw-byte reads beat Craft Anything string index on packed code.
`RV_TRN_02_smoothing_rules.md` — full 1,864-line parse, 118 active rules, road probs
0.5/0.375/0.125. `RV_TRN_03_water_bindings.md` — `heightmapwaves0.tga` negatively resolved;
`shore_prox` inert at `waveheight=0`.

## 11. Port implications, ranked

1. **Import donor light/sky colours** (DEC-03) — largest unimported visual constant set.
2. **Terrain ground texgen** stay APPROX (eye planes UNVERIFIED); 2 m/cell is donor-grounded.
3. **Alpha patch grid** now implementable (64² sub-rects) but tile→patch selection still UNVERIFIED.
4. **Selection rectangle** must be yellow 1 px solid, world-space 0.005 m threshold, Shift=add.
5. **Minimap** bottom-right 240×240; frustum box engine-drawn (port gap, separate ticket).
6. **Animation** skinning cannot claim donor parity without rendered A/B; frame-0 **bind pose is confirmed** (335/335), DEC-04's refutation is dead — see §13.4.
7. **Gameplay** market/famine/morale/hotkey findings are future tranche inputs, not today's fixes.

## 12. Open questions

**Closed as CONFIRMED_INFEASIBLE by `../reports/DBIND_01_wus_bind.md` (three constants):** native
ground eye planes / texture matrix, numeric FOV/focal→FOV body, and the native selection
inside-box predicate — the packed `.bind` payload has no recognizable container/compression/XOR
structure and Craft Anything refuses it, so no value can be recovered. Keep the labelled PORT
APPROXIMATIONs (`FOV_DEG_ASSUMED=17.27`, world-XZ texgen, script-side selection spec).

Still open (unchanged): `bmTransparency` pass count and blend factors; `hmapTex`/reflection
engine bindings; donor sprite vertex count semantics; mission/trigger details (D-12 deferred).
All are explicitly `UNVERIFIED` in the source reports and must never be filled with invented
values. `../CORRECTIONS.md` §"Claims that stay UNVERIFIED" is the authoritative list.

Late dives add further `UNVERIFIED` items (do not promote): tile→alpha patch index (DALPHA-01
§8 Q1), relief engine blend / flip / mountain selection (DPATTERN-01 §9), PFX numeric units and
rendered output (DFX-01 §12), donor engine skin form and quaternion convention (DANIM-01 §6.3),
fog `+1` bridge / sky-sun precedence (DENV-01 §7), GL `w`/modelview submission (LIGHT-02 §7),
ghost appearance and port F2 ordering (DBUILD-01 §8). None grants a visual-parity claim.

---

## 13. Late deep dives (Batch I, 2026-11-25) — appended after lane closure

Twelve reports landed after DEC-01…08 closed the lane. This section only **summarises** their
verdicts; every bullet carries a report path and a label `[observed]` / `[derived]` /
`[inferred]` / `[UNVERIFIED]`. `DSEASON_01` and `DONAVAL_01` were not present in `../reports/`
at refresh time and are **not** summarised — do not infer their contents. For reversals,
`../CORRECTIONS.md` (57 rows) is authoritative. **No donor visual-parity claim is made.**

### 13.1 `../reports/DALPHA_01_alpha_subrect.md` — alpha sub-rects
- `[observed]` Two decoders: `alpha.bmp` is 8 columns × 4 rows × 64² patches (32 rectangles),
  seam deltas exactly at multiples of 64; pixel array @1070; `reftile.lib:10-12`.
- `[observed]` All 245 `tiles.lib` sections inventoried: 8 families at 64/2/2 (sand1–4 +
  `_winter`), two Summer-only 128 overrides, 235 defaults; **no alpha-atlas override**, so every
  tile id shares the atlas; `tiles.mat` adds no geometry.
- `[derived, PARTIAL]` Complement structure exists only for four constant sentinels (best graded
  MAD 9.77); counterpart `(r,c)↔(3−r,3−c)` and darkness-ranked rows N/W/E/S are derived.
- `[CONFIRMED_UNVERIFIED]` `tile_id + boundary_direction → patch` rule: 17,237-file scan, 0 patch
  index function names; alpha UV comes from engine `gl_MultiTexCoord1` (`hf.pvl.sm.vert:34`).
  Keep the 64² sub-rect sampling APPROX with the A/B knob; backed by Craft Anything `fnd_7..fnd_9`
  (`RV_TRN_01_texgen_mask_reverify.md`).

### 13.2 `../reports/DPATTERN_01_relief_grids.md` — relief grids
- `[observed, 2 passes]` `.pattern` = `w×h` u8 occupancy grid + row-major `w×h` float32 height
  window; 26 grids reproduce `pattern.lib` min/max exactly (e.g. `k_ravine_1` G=2866 / 11,592 B,
  −2.963627576828003 / +3.139820098876953 = `pattern.lib:549585-549586`).
- `[observed]` 680/680 patterns are `NativeSeason=Summer`, `Winter=True` — no winter grid.
  Mountain patterns have all-zero grids and embed 1–5 `terrainmeshN` props: add props, not bumps.
- `[UNVERIFIED]` engine blend order/clamp, row→Y flip, runtime mountain selection. Port
  `game.gd:858-864` / `mapgen.gd:63-73` still lack grids; §8's 8×10 tables are debug aids only.

### 13.3 `../reports/DFX_01_pfx_effects.md` — PFX effects
- `[observed]` PFX is **text**, not packed binary (`section.begin`, no version): 44
  `source.pfx` sources, 24 `fx.tree` effects (6 `refkey` children expanded), 5 `manager.lib`
  managers, 22 materials, 90 FX DDS + 6 BMP (DDS 124-B header, DXT1/DXT5).
- `[observed]` Exact constants: volley smoke `fx.tree:4-63` / `source.pfx:30-64` (`musketsmoke`
  EndFrame 127, PixelRatio 175, AlphaTime 1.5), muzzle `source.pfx:102-178`, trails
  `source.pfx:1731-1803,2304-2339`, weather `env\pfx\particles.snow.cfg:2-158` (4 emitters,
  Weather 70–100; default `Weather=40` → snow inactive).
- `[correction]` No construction-dust FX; visible building smoke is damage smoke; selection is
  engine-side, not PFX. `[UNVERIFIED]` numeric field units and rendered output. No parity claim.

### 13.4 `../reports/DANIM_01_action_ranges.md` — AAF catalog + bind pose
- `[observed]` 246 `.aaf`, 1,434 active rows, **62 action names**, all `morph`; duration
  `(last−first+1)/30` s (donor movie helper uses exclusive `(ef−sf)/30`, `movie.script:857-858`).
- `[observed, two methods]` Frame 0 is the bind pose in **335/335** `.oss` files (max \|p\|
  1.09e−6 m, \|q−I\| 3.02e−8); DEC-04's refutation was a bone-major-as-frame-major indexing
  artifact (§6.2 A/B/C). Bone parents are absent but pre-folded.
- `[UNVERIFIED]` donor engine skin form at non-bind frames, quaternion convention, rendered A/B.
  Evidence ids: sequential `read_oss` + bone-major offset census; `fnd_1..fnd_6` carried in `DEC_04`.

### 13.5 `../reports/DBIND_01_wus_bind.md` — WUS `.bind`
- `[observed, 5 methods]` Three-region layout: 768-B per-binary header
  `cossacks.exe:0x55c600..0x55c8ff`; 11,264-B shared plaintext x86 loader
  `:0x55c900..0x55f1ff` (98.4 % identical across four EXEs, `.cdx` entry `:0x55c910`); ~135 KB
  opaque payload `:0x55f200..0x58036f`; API hash `0x488781ed` @`:0x55d804`. No container found.
- `[CONFIRMED_INFEASIBLE]` eye planes, numeric FOV conversion, native selection predicate (§12).
  `[inferred]` WUS = CODEX Steam-emulator marker. `[UNVERIFIED]` payload algorithm and final
  stub jump target. No visual claim.

### 13.6 `../reports/DENV_01_environment.md` — environment / season
- `[observed, twice]` Static config rig: `time.cfg:5` fixed 10:00, sun `light.cfg:3-36`, two-band
  sky `skydome.cfg:8-55`, `Weather=40` picks `soft*` presets (`clouds.weather:3`). Four fog
  mechanisms; scene fog `colors.lib:23,34-43` / `env.cfg:16` = `(60,100,150,1)` at 390–490;
  `FogMode=0` ambiguous and sky labels inverted (§9).
- `[observed]` Season = set swap: `terrain.lib:12-15`, two 124-entry `terrain.presets` tables,
  desert `gen.season=3`, all 12 `.palette` files byte-identical. `[UNVERIFIED]` `season=1`,
  swap-script runtime activity, fog bridge, sky/sun precedence. No code changed.

### 13.7 `../reports/DFORM_01_formations_morale.md` — formations / morale
- `[observed, twice]` No numeric morale/rout/panic/veteran/experience: 373 code files, 0 hits;
  93 `morale`-family hits across all files are locale narrative. Human-only disband
  `count < 0.25×basecount` (`dmscript.global:156`; `progress.inc:5-35,174-175`), shooter retreat =
  move mode 2 (`dmscript.global:657`), AI force-based retreat. The 3 `fear` code hits are one AI
  local bool.
- `[observed]` Port `MORALE_*`, squad XP and famine HP drain are inventions. `[UNVERIFIED]`
  binary-only behaviour; no numeric morale may be added.

### 13.8 `../reports/DUNIT_01_unit_roster.md` — unit roster
- `[observed]` ~90 trainable sids from `unit.script`/`country.script`/`units.txt` (not `*.prop`);
  six resources **F/W/St/G/I/C** (`U:493-501`), `cost=floor(base×(costpercent/100)^owned)`
  (`U:5652-5689`), build time `frames÷32 s` (`U:571-581`), buildings ×10 `gc_buildtime_modifier`
  (`G:180`).
- `[observed]` Port has 62 `UNITS_BASE` keys / 21 nations; 10 missing national uniques;
  `highlander` is **England's** 18c shooter (`C:2715`), not Austria/Hungary. `[UNVERIFIED]`
  per-unit population, braced `{a;b;c}` values, PX_TO_M.

### 13.9 `../reports/DAUDIO_01_sound_events.md` — sound events
- `[observed, twice]` 247+51+27 = **325** declared clips = 325 on-disk Oggs; 59 live donor sound
  indices of 89; all 325 present in the port.
- `[observed]` Selection `selectpeasant1..6` + `selectship` are interface-bank,
  **non-positional** `_sound_PlaySound` from `showunitcontrol.inc:1024-1027`; every order-ack
  registration commented / constants undefined. Radii `loudness*1.25` = 25/50/75/100, UI 8000,
  `maxradius=0`.
- `[UNVERIFIED]` loudness units, donor DSP curve, panning; musket grouping inactive. No
  spatial-parity claim.

### 13.10 `../reports/DMAPGEN_01_skirmish_options.md` — skirmish options
- `[observed, 2–3×]` 4 sizes **256/320/480/640** (`donewgame.inc:42-49`, GUI order `:243-246`),
  9 shapes + Random, 5 relief + Random, 3 mineral densities, 4 starting resources, 3 seasons
  **0/2/3** + Random (no selectable 1; `showcustomgame.inc:182-201`), teams 0..4, 5 visible AI
  labels.
- `[observed]` Seed = 64-bit `randkey0/1` with 11 reseed sites and version gates <53…<91; port
  240/320/400/480 and "Thousands" 25× vs donor 5× diverge. `[UNVERIFIED]` AI tag/id
  reconciliation and runtime consumption in the port.

### 13.11 `../reports/DBUILD_01_building_stages.md` — building stages
- `[observed/derived]` Construction = 4 stages `floor(progress*4)` → mesh suffix 1–4 plus
  finished base, scaffold child, 2 death stages (30+30 frames, ×2 mines), debris; walls use 2
  stages and no death mesh.
- `[observed]` Ghost = engine dummy (colour/size UNVERIFIED); rally = 3D object scale 0.0525 /
  roll 45 (`rallypoint.prop:19-21,25`); completion jingle `bld<sid>` (`interface.snd:80-121`);
  no construction dust, damage smoke onset ≈ 88.75 % HP on finished buildings only.
- `[UNVERIFIED]` stage mesh visual content, ghost appearance, port F2 runtime ordering. No
  parity claim.

### 13.12 `../reports/LIGHT_02_light_space.md` — donor light space
- `[derived, 4-way]` Donor world is **Y-up**; `light.cfg:26-31`
  `Position=(-0.344731152057648,+0.938701450824738,0,1)` is a unit world sun direction with Y as
  elevation, `lsParallel` (`:17`), W=1; `light.ref:13-16` radius 20000 = `env.cfg:6` flare orbit;
  `default.cameras` `UpY=1`; `water.dev.vert:22` is a water-local Z-up conversion, **not** a world
  Z→Y mapping.
- `[derived]` Godot equivalent `sun_world=normalize(P.xyz)` rotated by `VIEW_MATRIX` → flat-ground
  `dot=0.938701` at any tilt. TERRAIN-DARK-FIX's landed `(x/4,y,z/2)` is axis-correct but a PORT
  APPROX (`dot=0.995812`); module `SUN_LIGHTVEC:138` remains un-swapped.
- `[UNVERIFIED]` GL `w`/modelview submission, strict row A vs C target, donor GPU A/B. No parity
  claim.

### 13.13 LFS / atlas transport (`../CORRECTIONS.md` row 53; `../reports/ATLAS_01_transport.md`)
- `[RESOLVED]` The 180 MB atlas PNG **is** Git-LFS tracked (134-B pointer in-tree, full local
  object); the ~180 MB split parts are ordinary Git blobs, so clone size is unchanged. Without
  LFS the pointer reaches `Image.load()` and the loader falls back to split. SHA-256 identity
  verified twice. Carried here because §9 needs the reversal.

---

**Related:** `README.md` · `EVIDENCE_INDEX.md` · `../CORRECTIONS.md` (authoritative, 57 rows) ·
`DEC_0x_*.md` · `../GAPS.md` · `../PLAN_IMPLEMENTATION.md` · `docs/decomp/` (prior lane) ·
`investigation.cany/investigation/` (Craft Anything memory).
