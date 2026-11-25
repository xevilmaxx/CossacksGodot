---
title: DONOR DECOMPILATION — consolidated findings (2026-11-25)
area: donor decompilation
owner: COORD (aggregates DEC-01…DEC-08 + RV re-verifications)
updated: 2026-11-25
status: lane closed
---

# 🔬 Donor decompilation — consolidated findings

**Lane closed.** Eight micro-workers documented the installed donor at
`C:\Games\Cossacks 3` read-only (Python `bytes`/latin-1, Craft Anything read tools, short
hex excerpts). No donor binary was executed or copied into the repo. This file consolidates
their results and the cross-lane re-verifications that amended them. Full detail, claim tables
and evidence ids live in the eight `DEC_0x_*.md` records; `EVIDENCE_INDEX.md` indexes the ids.

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
- **Correction to DEC-04 (which had itself "corrected" DEEPDEC-06):** DANIM-01 refuted
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

| Prior claim | Corrected by | Truth |
|---|---|---|
| `.cdx` entry in `.bind` for `.exe` too | DEC-01 | Only `.cdx`; `.exe` entry in `CODE` |
| "no FOV token in donor" | DSEL-02 / DEC-07 | API exists, runtime-derived; numeric FOV UNVERIFIED |
| `.inc` scripts commented out | RV-SEL-01 / RV-CAM-01 | `[*]=;` = live code; `//` = real comment |
| DEC-07 FOV arithmetic correction | RV-CAM-01 | 17.27° = correct V-FOV; 5.15/30.22 = H-FOV |
| `TILE_M=2.0` is port-only | DEC-05 | donor `gc_meters_to_tile=2` |
| 243 hotkey bindings | DEC-03 | 55 bindings in 243 lines |
| 43 non-zero formations | DEC-03 | 46 |
| envscales all ±15% | DEC-03 | three bands (0, ±5%, ±15%) |
| DEC-04: frame 0 is NOT bind for multi-bone | DANIM-01 | **DEC-04 refuted**: 335/335 frame-0 identity (max |p| 1.09e−6 m, `peaukr` skin f0 1.52e−7 m); DEEPDEC-06 F4/F5 confirmed; DEC-04's Method C misread bone-major as frame-major |
| "733/733 skin verts" | DEC-04 | OBJ `vt` count; `.oss` v=577 |
| `heightmapwaves0.tga` = `hmapTex` | DEC-05 / RV-TRN-03 | commented only, alpha all 255 |
| no donor tile-index file | DEC-05 / DEC-06 | `.map` has 37-byte per-cell records |
| donor has numeric morale | DEC-02 | no; disband `count<0.25×base` |
| donor patrol hotkey | DEC-02 | none (`Q`=viewcollision) |

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
6. **Animation** skinning cannot claim donor parity without rendered A/B; frame-0 bind claim dead.
7. **Gameplay** market/famine/morale/hotkey findings are future tranche inputs, not today's fixes.

## 12. Open questions

**Closed as CONFIRMED_INFEASIBLE by `../reports/DBIND_01_wus_bind.md`:** native eye-plane
values, numeric FOV/focal→FOV body, and the native selection inside-box predicate — the packed
`.bind` payload has no recognizable container/compression/XOR structure and Craft Anything
refuses it, so no value can be recovered. Keep the labelled PORT APPROXIMATIONs.

Still open: `bmTransparency` pass count;
`hmapTex`/reflection engine bindings; native selection inside-box predicate; donor sprite
vertex count semantics; mission/trigger details (D-12 deferred). All are explicitly
`UNVERIFIED` in the source reports and must never be filled with invented values.

---

**Related:** `README.md` · `EVIDENCE_INDEX.md` · `DEC_0x_*.md` ·
`../GAPS.md` · `../PLAN_IMPLEMENTATION.md` · `docs/decomp/` (prior lane) ·
`investigation.cany/investigation/` (Craft Anything memory).
