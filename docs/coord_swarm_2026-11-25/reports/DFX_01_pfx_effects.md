---
id: DFX-01
title: Donor FX / particle / PFX definitions — formats, emitters, constants and skirmish relevance
area: donor / decompilation / FX deep-dive
owner: DFX-01 (donor deep-dive micro-worker)
date: 2026-11-25
status: COMPLETE — documentation only; no code edits, no runner jobs, no donor copies
donor: "C:\Games\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1; no donor executable run or copied)"
method: "3 independent passes: (A) byte/hex format recon of every effect file family, (B) plaintext reference-chain reconstruction through scripts/configs, (C) raw-byte string finders on cossacks.exe / codex.dll"
labels: "observed / derived / inferred / UNVERIFIED; each structural claim checked two ways"
---

# DFX-01 — Donor FX/particle/PFX definitions, deeply documented

## 1. Goal

Close the one donor aspect still marked BLOCKED/UNVERIFIED: the **binary/text
formats, emitter parameters and exact constants** of Cossacks 3 effects, and
their relevance to single-player skirmish. Specifically:

1. Enumerate every effect-related file under donor `data` and identify its real
   format (magic, version, header fields, byte offsets, record layout).
2. Recover emitter parameters (rate/lifetime/velocity/gravity/size/colour/
   texture/blend) and the script→effect reference chain from units, weapons and
   buildings.
3. Extract exact constants for the seven skirmish-visible FX classes requested
   (volley smoke, muzzle flash, arrow trails, construction dust, death/
   explosion, weather particles, selection highlight), labelled by evidence
   strength.
4. Independently search `cossacks.exe` and `codex.dll` with raw byte finders for
   effect API names and numeric tables (the Craft Anything string index can miss
   CODE-resident literals).
5. Compare, read-only, against `variant3d/scripts/world3d_fx.gd` and
   `anim3d.gd`; document present / approximated / absent **without proposing
   changes**.

**Guardrails honoured.** Donor files were opened in place with `bytes` and
decoded `latin-1`; no donor binary was executed, no donor bytes were copied into
the repository, no Godot runner job was started, and no file other than this
report was written. Temporary analysis scripts lived only in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.

**Labels.** *observed* = literal bytes/text read or tool output; *derived* =
arithmetic/control flow following directly from observations; *inferred* =
strong but indirect interpretation; *UNVERIFIED* = no readable evidence or no
unit conversion provable from read-only data.

**Two-way verification.** Every format claim below was checked by (1) a direct
`struct`/line read and (2) an independent method: cumulative-CRLF byte-offset
arithmetic plus direct byte re-read at the computed offset, whole-family size
closure, a second reader (Craft Anything `read` vs Python), or a hexdump.
Verified offsets are listed in §5.7.

---

## 2. Sources

### 2.1 Prior documents read (as instructed)

| # | Document | What it contributed / how this report treats it |
|---|---|---|
| P1 | `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` | §D-14 (`:857-895`): `lib/pfx.script` = pool with `Create/GetOrCreate/SaveToStruct/LoadFromStruct` and `FillRand` (`:200`); projectile explosion media/decal rules; "no `weather` token in scripts" (`:865-870`); FX explosion cite (`:1065`). **Extended here**: the pool's randomisation semantics are now decoded from `:39-86`; the weather gap is filled by a separate data family. |
| P2 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` | §5 (`:375-389`) binds `data\actors\pfx\shot\shotmusket{1,2}.actor` → `pfx\pfxshotmusket{1,2}.aaf` + `shotmusket{1,2}.oss`, i.e. a shot also has an animated 3D mesh. Used in the port comparison; **not** confused with PFX sprites. |
| P3 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_07_fx_audio.md` | RTTI of PFX names/APIs, 10 `pfx*` kinds, 44 `source.pfx` entries, 24 `fx.tree` effects, per-key field tables for four keys. **Corrected/extended here**: four `fx.tree` `{refkey}` children and all 24 effects are expanded with byte offsets; `rand*` codes are decoded from the consumer; weather particles were missed there; file offsets of the same RTTI are given. |
| P4 | `docs/coord_swarm_2026-11-24/reports/V715_world3d_fx.md` | Port module design; explicitly labels PFX semantics UNMAPPED (`:48-65`) and quotes literal keys. **Superseded here** for semantics, but its port-lifetime/coordinate facts are retained. |
| P5 | `docs/coord_swarm_2026-11-24/reports/V773_fx_world_offset.md` | FX world-origin fix: `world_offset = (MAP_W,MAP_H)*0.5*TILE_M` (`:32-43,108-143`). Read-only cross-check of the port module; no change proposed. |
| P6 | `docs/audit/PIECES/water_glints.md` | Donor water glints are **shader** specular terms (`water.dev.frag:42-43,47,218-226`), not PFX; port has `×8/×4` amplitude and constant-light defects (`:67-80`). Included as the scope boundary for "water FX": `waterblast*` are impact splashes, not glints. |

### 2.2 Donor files measured in this pass (all read-only)

Prefix `C:\Games\Cossacks 3\data\` throughout this report unless stated.
`cossacks.exe` / `codex.dll` are at `C:\Games\Cossacks 3\`.

---

## 3. File inventory (observed)

### 3.1 The PFX core — `data\pfx\` (6 text + 20 textures, 52.1 MB total)

| Path | Bytes | Class | Role |
|---|---:|---|---|
| `pfx\source.pfx` | 80,545 | ASCII OSW config, CRLF, 0 NUL | 44 sprite/trail source records (`LibSourceID 0..43`) |
| `pfx\source.ref` | 3,442 | ASCII OSW config | single `animatedsprite` default template (`refurl` target of every `source.pfx` record) |
| `pfx\fx.tree` | 18,414 | ASCII OSW config | 24 named effects `[0..23]`, each with `libeffects[i]` overrides |
| `pfx\manager.lib` | 746 | ASCII OSW config | 5 PFX managers (type + shader id) |
| `pfx\material.mat` | 14,906 | ASCII OSW config | 22 PFX material records (texture, blend, tint) |
| `pfx\material.ref` | 2,734 | ASCII OSW config | single `Material` default template |
| `pfx\textures\*` | 49,024,812 | 18 DDS + 2 BMP | sprite sheets: smoke/flash/sparks/explosions/water/trail |

Texture names (observed): `blank.bmp`, `bullettrail.bmp`, `cannonexp.dds`,
`cannonflash.dds`, `debris.dds`, `distexpflare.dds`, `distexpring.dds`,
`firepalette.dds`, `firesmoke.dds`, `grenadeexp.dds`, `impactsmoke.dds`,
`musketflash.dds`, `musketflashup.dds`, `musketsmoke.dds`,
`musketsmokenorm.dds`, `musketsmoketbn.dds`, `musketsmokeup.dds`,
`musketsparks.dds`, `standingsmoke.dds`, `waterblast.dds`.

### 3.2 The **weather particle system** — `data\env\pfx\` (7 files, 31,244 B) — NEW for this lane

| Path | Bytes | Role |
|---|---:|---|
| `env\pfx\particles.lib` | 307 | one manager record `Name = snow`, `ParticleCollectionFileName` |
| `env\pfx\particles.snow.cfg` | 3,557 | **4 emitter records** `snow1..snow4` with speed/count/weather band |
| `env\pfx\particles.mat` | 10,772 | 4 material records `snow1..snow4` |
| `env\pfx\textures\snow{1,2,3,4}.bmp` | 4 × 4,152 | sprite bitmaps |

This family is the answer to "weather particles" and was **not** present in any
prior FX report. It is a different engine system from PFX (`particles.lib`
→ `ParticleCollectionFileName`, no `source.pfx`/`fx.tree`).

### 3.3 Secondary effect art and object records

| Family | Count | Bytes | Content |
|---|---:|---:|---|
| `materials\pfx\` | 68 DDS + `pfx.mat` (14,324 B) | 1,436,532 | mesh/shot/debris/trail/impact art; `pfx.mat` names `buildfire{1,2,3}` + `_birth`, `buildsmoke{1,2,3}` + `_birth`, `debris`, `impdust{1,2,3}`, `trailfire{1,2,3}`, `expl{cannon,building,grenade}*`, `proj*`, `shot*` |
| `materials\ref\refpfx.mat` | 1 | 260 | material template for the above |
| `terrain\decals\pfx\` | 4 DDS | 1,398,720 | `groundexp0..3.dds` ground explosion decals (512×512 DXT5) |
| `objects\misc\pfx\` | 8 `.prop` | 13,674 | `projarrow`, `projcannonball`, `projgrenade`, `projhowitzerball`, `projhowitzerballfragment`, `projmortarball`, `debris_stone`, `debris_wood` |
| `brushes\brushes.mat` + `brushes\textures\` | 1 + 17 (13 DDS, 4 BMP) | 3,765,096 + mat | selection/highlight materials and rings (§7.7) |
| `scripts\lib\pfx.script` | 1 | 17,880 | effect library consumer (`gEffectLibrary`) |
| `scripts\lib\weapon.script`, `scripts\lib\unit.script`, `scripts\misc\projectile.inc\*`, `scripts\units\building.inc\nothing.inc`, `scripts\lib\gui.script`, `scripts\lib\init.script` | — | — | reference chain (§8) |
| `shaders\obj\fx.id29.frag/.vert`, `fx.id30.frag`, `fx.id31.frag`, `fx.tbn.id30.*` | 6 | ~8 KB | the three PFX shader behaviours (§5.6) |

**Negative inventory (observed):** there are **no** `.fx` or `.part*` files
anywhere under donor `data`; the only effect `.cfg` files are the two weather
files (`particles.snow.cfg`, plus `env\clouds\clouds.weather` with extension
`.weather`). All "effect config" content lives in `.pfx`, `.tree`, `.lib`,
`.mat`, `.ref`, `.cfg` and `.prop` OSW-config text.

---

## 4. Master format finding: PFX is **text**, not a packed binary

**Correction to the ticket's working assumption and to prior "binary format is
BLOCKED" framing.** `source.pfx`, `fx.tree`, `manager.lib`, `material.mat`,
`source.ref`, `material.ref`, weather `particles.*`, and the `.prop` records are
all the same **OSW config dialect** already documented for `.acl`/`.snd` in
DEC-04 §4.4. Evidence (two ways):

- Python: byte 0 of each file is ASCII `section.begin` **or** a leading
  `{refurl=...}` inheritance prefix followed by `section.begin`; **zero `0x00`
  bytes** in all files; CRLF line endings (e.g. `source.pfx`: 2,893 CRLF for
  2,894 lines; `fx.tree`: 537 CRLF / 538 lines; `manager.lib`: 36 CRLF / 37
  lines); strict `latin-1` decode succeeds.
- Craft Anything `read` of the same files shows identical lines and line
  numbers (§2.1 citations) and reports plain text.
- **Magic/version:** magic is the ASCII token `section.begin` (`73 65 63 74
  69 6f 6e 2e 62 65 67 69 6e`) at `0x0` (or at the first line after a
  `{refurl=...}` prefix); **there is no numeric version field** anywhere.
  Endianness is N/A for these text files; the only binary family in FX is DDS
  (§5.5) and BMP.

`source.pfx:0x0000` hex:
```
73 65 63 74 69 6f 6e 2e 62 65 67 69 6e 20 7b 72 65 66 75 72 6c
3d 2e 5c 64 61 74 61 5c 70 66 78 5c 73 6f 75 72 63 65 2e 72 65
66 7d 0d 0a ...        ; "section.begin {refurl=.\data\pfx\source.ref}\r\n"
```
`fx.tree:0x0000` hex:
```
73 65 63 74 69 6f 6e 2e 62 65 67 69 6e 0d 0a 20 20 20 20 65 66
66 65 63 74 6c 69 62 72 61 72 79 20 3a 20 73 74 72 75 63 74 2e
62 65 67 69 6e ...      ; "section.begin\r\n    effectlibrary : struct.begin"
```

---

## 5. Per-format layout tables (byte offsets)

### 5.1 `source.pfx` — source/sprite descriptor records

**44 records** (observed; `LibSourceID 0..43`). Section starts, computed by
cumulative CRLF length and re-read directly: first record `0x0000` (line 1),
second `0x02F7` (line 30), `bullettrail` `0xBEB2` (line 1731), last
`waterblastsmall` `0x1362D` (line 2853). Every computed offset re-read as
`section.begin` (§5.7). No padding; section length = sum(line bytes + 2).

Record schema (observed on all 44):

| Field | Type | Meaning / default source | Example (`musketsmoke`) |
|---|---|---|---|
| `section.begin {refurl=...}` | text | inherits `source.ref` defaults | `source.pfx:1` |
| `LibManagerName` | string | manager in `manager.lib` | `aspriteshader31` `:31` |
| `LibSourceID` | int | 0-based record id, matches array index | `1` `:32` |
| `LibSourceName` | string | key used by `fx.tree` `sourcename` | `musketsmoke` `:33` |
| `animatedsprite : struct.begin` | text | behaviour class from `source.ref:6` | `:34` |
| `Animations[*]` / `Animations : struct.begin` | nested records | frames; see below | `:38-50` |
| `Position`, `Scale`, `Direction`, `Up` | `struct` XYZ | vectors | `:54-58` |
| `PixelRatio`, `FrameRate`, `Interval`, `AlphaTime`, `AlphaPower` | float/int | size and timing | `:51,53,46,61,62` |
| `OnEndFrameState` / `OnEndFrameHide` | enum/bool | `FreeToPool` / hide | `:60` / `:176` |
| `MirrorU/MirrorV`, `NoZTest`, `AxisAligned`, `AnimationMode` | bool/enum | orientation/blend policy | `:52,166` |

`Animations` has two forms (observed): a single `[*]` block (e.g.
`musketsmoke:38-50`) or an indexed list of 4 single-frame blocks (e.g.
`musketflash:110-163`). Inner fields are fixed:
`CurrentFrame`, `StartFrame`, `EndFrame`, `FrameWidth`, `FrameHeight`,
`LibMaterialName`, `Dimensions = sfdAuto`, `Interval`, `FrameRate`,
`ImageWidth`, `ImageHeight`. `trail` records replace these with
`VertLimit, TimeLimit, MinDistance, Alpha, AlphaFade, UVScale, MarkStyle,
MarkWidth, ZWrite, ZTest, UseDiff, Diffuse(RGBA)` (`source.pfx:1739-1763`).

Short hex excerpt (`path:offset` verified):
```
data\pfx\source.pfx:0x045D  45 6e 64 46 72 61 6d 65 20 3d 20 31 32 37
                            ; "EndFrame = 127"  (musketsmoke)
data\pfx\source.pfx:0x0571  50 69 78 65 6c 52 61 74 69 6f 20 3d 20 31 37 35
                            ; "PixelRatio = 175"
data\pfx\source.pfx:0x0BFA8 54 69 6d 65 4c 69 6d 69 74 20 3d 20 30 2e 32
                            ; "TimeLimit = 0.2" (bullettrail)
```

### 5.2 `fx.tree` — named effect compositions

**24 effects `[0..23]`**, 6 of them `{refkey=...}` inheritance children (`[1],[2],[3],[7],[13],[14]`).
Records run from `0x0000` (line 1); `[0] shotmusket` `effectname` at line 4 /
`0x004A`; `[9] impactsmoke` at line 254 / `0x222B`; `[23] waterblastsmall` at
line 522 / `0x45D0`.

| Field | Type | Meaning | Example |
|---|---|---|---|
| `[i] : struct.begin {refkey=.effectlibrary[n]}` | text | inherit another effect then override | `[1]`, `[2]`, `[3]`, `[7]`, `[13]`, `[14]` |
| `effectname` | string | key passed to `gEffectLibrary.GetOrCreate` (§8) | `shotmusket` `:4` |
| `effectoffset` XYZ | float | world offset applied to every layer | cav `-0.025,-0.175,0.33` `:66-68` |
| `ownerpitch` / `ownerroll` / `ownturn` | float | rotate owner before emitting | `50` for howitzer/mortar `:133,166` |
| `parentrandom` | bool | one shared 8-float random set for all layers | `grenadeexp:217` |
| `libeffects[i]` | records | layer list; `keyname`, `sourcename`, `sourcetype` + `rand*` overrides | `shotmusket:6-60` |

Complete effect→layer table with exact lines (observed):

| # | effectname (line) | layers (line of `keyname`) / note |
|---:|---|---|
| 0 | `shotmusket` (`:4`) | musketsmoke `:7`, musketflash `:26`, musketsparks `:32`, musketsmokeup `:38`, musketflashup `:49` |
| 1 | `shotmusketcav` (`:64`) | inherits `[0]`; offset + `randposition` overrides `:70-75` |
| 2 | `shotmusketking` (`:78`) | inherits `[0]`; offset only |
| 3 | `shotmusketdrag` (`:86`) | inherits `[0]`; offset + y overrides `:92-97` |
| 4 | `shotcannon` (`:100`) | cannonsmoke `:103`, cannonflash `:116`, cannonsparks `:122` |
| 5 | `shothowitzer` (`:132`) | howitzersmoke `:136`, howitzerflash `:149`, howitzersparks `:155`; `ownerpitch=50` |
| 6 | `shotmortar` (`:165`) | mortarsmoke `:169`, mortarflash `:182`, mortarsparks `:188`; `ownerpitch=50` |
| 7 | `shotmcannon` (`:198`) | inherits `[0]`; offset + x/y overrides `:204-213` |
| 8 | `grenadeexp` (`:216`) | grenadeexp `:220`, grenadesmoke `:232`, distexpflare `:244`, distexpring `:248`; `parentrandom=true` |
| 9 | `impactsmoke` (`:254`) | impactsmoke `:257`, distexpring `:267` |
| 10 | `impactdust` (`:274`) | impactdust `:277` |
| 11 | `cannonexpground` (`:290`) | cannonexp `:293`, cannonexpsmoke `:305`, distexpflare `:317`, distexpring `:321` |
| 12 | `cannonexpbuilding` (`:327`) | cannonexpbuilding `:330`, distexpring `:340` |
| 13 | `howitzerexpground` (`:347`) | inherits `[8]`; pixel-ratio overrides `:348-351` |
| 14 | `howitzerexpbuilding` (`:354`) | inherits `[8]`; same overrides `:355-358` |
| 15 | `bullettrail` (`:361`) | bullettrail `:364` |
| 16 | `firearrowtrail` (`:370`) | firearrowtrail `:373`, firearrow `:377` (pixel-ratio ±50%) |
| 17 | `fragtrail` (`:389`) | fragtrail `:392` |
| 18 | `expflash` (`:398`) | distexpflare `:402`, distexpring `:409`; `parentrandom=true`, pixel-ratio −30% |
| 19 | `buildingsmoke` (`:418`) | buildingfirestart `:422`, buildingsmokestart `:427`, buildingfire `:432`, buildingsmoke `:437`; `parentrandom=true` |
| 20 | `shottower` (`:444`) | towersmoke `:447`, towerflash `:460`, towersparks `:466` |
| 21 | `shotmusketpoint` (`:476`) | musketsmokepoint `:479`, musketsparkspoint `:498` |
| 22 | `waterblast` (`:506`) | waterblast `:509` |
| 23 | `waterblastsmall` (`:522`) | waterblastsmall `:525` |

**No** `arrow`, `firearrow` (as effect), `framexp` or `standingsmoke` effect
record exists (confirmed by targeted grep). A `GetOrCreate` lookup of an absent
key returns −1 (`pfx.script:353-360`) → no FX silently.

### 5.3 `manager.lib` — the 5 manager records

`manager.lib:1-37`, each `section.begin` with 4–5 fields:

| Manager | PFXType | Sorting | ShaderID | VisibilityCulling | lines |
|---|---|---|---:|---|---|
| `aspriteblank` | `pfxAnimatedSprite` | `assMaterial` | −2 | True | `:2-6` |
| `aspriteshader29` | `pfxAnimatedSprite` | `assMaterial` | **29** | True | `:10-14` |
| `aspriteshader30` | `pfxAnimatedSprite` | `assMaterial` | **30** | True | `:18-22` |
| `aspriteshader31` | `pfxAnimatedSprite` | `assMaterial` | **31** | True | `:26-30` |
| `trailbullet` | **`pfxTrail`** | — | — | True | `:34-36` |

This is the data-level proof that the smoke/flash records are `pfxAnimatedSprite`
and trails are `pfxTrail` (matching DEEPDEC-07 finding 2). Byte offsets of the
five `Name =` lines were read directly (file is 746 B, 36 CRLF).

### 5.4 `material.mat` / `material.ref` — material records

**22 records** in `material.mat` (first at `0x0000`, `musketsmoke` at
`0x0141`/line 10; `cannonflash` line 194/`0x14F9`; `bullettrail` line 441/
`0x2EEB`; `waterblast` line 512/`0x36AD`). `material.ref:1-109` is the single
template: `BlendingMode = bmAdditive`, `FaceCulling = fcNoCull`,
`moIgnoreFog=False`, `moNoLighting=False`, `Texture` defaults
(`tcHighQuality`, `tfAnisotropic16x`, `maLinear`, `miLinearMipmapLinear`,
`tmModulate`, `twBoth`), front/back `Diffuse=(0.8,0.8,0.8,0.5)`.

Observed overrides (observed; tint triples are identical R=G=B unless noted):

| Material | Texture | Blend | Diffuse tint (RGB / A) | Special |
|---|---|---|---|---|
| `blank` | `pfx\textures\blank.bmp` | `bmOpaque` | A=1 | tmDecal |
| `musketsmoke` | `musketsmoke.dds` | `bmTransparency` | **0.3137255** (=80/255) | — |
| `musketsmoketbn` | `musketsmoketbn.dds` | inherit | inherit | `ShaderTexEx[0].LibName=musketsmokenorm`, `TexIndex=1` (`:47-49`) |
| `musketsmokenorm` | `musketsmokenorm.dds` | inherit | inherit | normal/bump helper |
| `musketflash` | `musketflash.dds` | inherit | (1,1,1,1) | — |
| `musketsparks` | `musketsparks.dds` | inherit | (1,1,1,1) | — |
| `musketsmokeup`, `standingsmoke` | corresponding dds | `bmTransparency` | 0.3137255 | — |
| `musketflashup` | `musketflashup.dds` | inherit | (1,1,1,1) | — |
| `cannonflash`, `grenadeexp`, `cannonexp` | corresponding dds | inherit | (1,1,1,1) | `LibName=firepalette` at `:199,:229,:291` |
| `grenadesmoke`, `cannonexpsmoke`, `impactsmoke` | `grenadeexp.dds`/`cannonexp.dds`/`impactsmoke.dds` | `bmTransparency` | 0.3137255 / impactsmoke **0.157** (=40/255) | — |
| `distexpflare` | `distexpflare.dds` | inherit | (1,1,1,**0.1**) | `firepalette` `:392` |
| `distexpring` | `distexpring.dds` | `bmTransparency` | (1,1,1,1) | — |
| `bullettrail` | `bullettrail.bmp` | inherit | inherit | 512×256 24-bit BMP |
| `buildingfire` | `firesmoke.dds` | inherit | **0.7843137** (=200/255), A=0.5 | `firepalette` `:453` |
| `buildingsmoke` | `firesmoke.dds` | `bmTransparency` | **0.1568627** (=40/255), A=0.75 | — |
| `waterblast` | `waterblast.dds` | `bmTransparency` | 0.3137255 | — |

**Sharing (observed, important):** `cannonsmoke` uses
`LibMaterialName = musketsmoke` (`source.pfx:388`); `impactdust` uses
`LibMaterialName = impactsmoke` (`:1280`); `fragtrail` and `firearrowtrail` use
`bullettrail` (`:1787,:2323`). These are intentional shared materials, not
typos to "fix" in a port.

### 5.5 Particle textures — DDS (the only binary FX asset format) and BMP

**DDS header (124 bytes, little-endian, observed on all 90 FX DDS files):**

| Off | Size | Field | Sample `pfx\textures\musketsmoke.dds` |
|---:|---:|---|---|
| 0x00 | 4 | magic `DDS ` | `44 44 53 20` |
| 0x04 | 4 | `dwSize` | 124 |
| 0x08 | 4 | `dwFlags` | `0x00A1007` |
| 0x0C | 4 | height | 2048 |
| 0x10 | 4 | width | 2048 |
| 0x14 | 4 | pitch/linear size | 4,194,304 |
| 0x18 | 4 | depth | 0 |
| 0x1C | 4 | `dwMipMapCount` | **12** |
| 0x4C | 4 | `ddspf.dwSize` | 32 |
| 0x50 | 4 | `ddspf.dwFlags` | 4 (DDPF_FOURCC) |
| 0x54 | 4 | FourCC | `DXT5` (or `DXT1`) |
| 0x6C | 4 | `caps` | `0x401008` |

Hex excerpt (`data\pfx\textures\musketsmoke.dds:0x0000`):
```
44 44 53 20 7c 00 00 00 07 10 0a 00 00 08 00 00 00 08 00 00 00
00 40 00 00 00 00 00 0c 00 00 00 00 00 00 00 00 00 00 00 00 00
```
Second verification: `struct.unpack_from('<6I',h,4)` gives
`(124,0xA1007,2048,2048,4194304,0)` and mips at `0x1C` = 12; file size
5,592,560 = full DXT5 mip chain (observed across 18 `pfx\textures` DDS).

Notable dimensions (observed): `musketsmoke/musketsmokenorm/musketsmoketbn/
musketsmokeup/cannonexp/firesmoke/waterblast` 2048×2048 DXT5; `musketflash`
512×256 **DXT1**; `musketsparks` 512×256 DXT1; `impactsmoke/grenadeexp/
standingsmoke` 1024×1024 DXT5; `distexpflare/distexpring` 256×256 DXT1;
`firepalette` **256×4 DXT1** (a 4-row palette used by shader 30/31);
`materials\pfx\*` mesh textures 128×128 DXT5; `projarrow.dds` 32×128 DXT1;
`terrain\decals\pfx\groundexp*.dds` 512×512 DXT5.

BMP (`pfx\textures\blank.bmp`, `bullettrail.bmp`): `BM` at 0x0, `bfSize`
at 0x2 (786,486 / 393,270), width/height at 0x12 (512×512 / 512×256),
24 bpp at 0x1C, pixel offset 54 at 0x0A (observed).

### 5.6 Shader semantics bound to `ShaderID` (observed)

| ShaderID | File | Colour / alpha behaviour |
|---:|---|---|
| 29 | `shaders\obj\fx.id29.frag` | plain texture: `color = tex0*(ambient+diffuse)+specular`; `color.a = tex0.a*diffuse.a` (`:21-25`). Used by musketflash, sparks, waterblast. |
| 30 | `shaders\obj\fx.id30.frag` | palette: `texr = tex0[int(randValue*randMax)*randStep+randBias]`; colour sampled from `texUnit1` (the 256×4 `firepalette`), `color.a = diffuse.a` (`:26-33`). Matches `randMax/randStep/randBias` uniform entries in `source.pfx:1332-1358`. |
| 31 | `shaders\obj\fx.id31.frag` | noise-smoke: `texr = tex0[...]`; `color = texr*(ambient+diffuse)+specular`; `color.a = diffuse.a*texr + clamp(texr-(1-diffuse.a),0,1)` (`:41-49`). Used by musketsmoke / cannonsmoke / building smoke. |

`fx.id29.vert` (731 B) and `fx.tbn.id30.vert` (865 B) are the matching vertex
programmes. Blending itself is `bmTransparency`/`bmAdditive` from `material.mat`,
not from the shader.

### 5.7 Weather particle emitter format — `env\pfx\particles.snow.cfg`

ASCII OSW config, 4 `section.begin` records (`snow1` line 2 / `0x00000F`,
`snow2` line 42, `snow3` line 82, `snow4` line 122), inner records `CreatingCubeStart`,
`CreatingCubeEnd`, `MoveDirection`. Schema (observed on all 4):

| Field | snow1 | snow2 | snow3 | snow4 | line (snow1) / byte off |
|---|---:|---:|---:|---:|---|
| `Height` | 0.00150000012945384 | 0.0020000000949949 | 0.00251000002026558 | 0.00300000025890768 | `:4` |
| `Width` | same as Height | same | same | same | `:5` |
| `AlphaChannel` | 0.5 | 0.5 | 0.5 | 0.5 | `:6` |
| `NoZWrite` | True | True | True | True | `:7` |
| `WindInteraction` / `WeatherInteraction` | False / False | False / False | False / False | False / False | `:10-11` |
| `Rotation` | 62048.2890625 | 66374.140625 | 73513.21875 | 122149.078125 | `:12` |
| `SpiralRotatingRadius` | 0.100000001490116 | ~0.1 | ~0.1 | ~0.100000098 | `:14` |
| `SpiralRotatingSpeed` | 20 | 15 | 13 | 13 | `:15` |
| `BillboardType` | `btBillboard` | same | same | same | `:16` |
| `CreatingCubeStart/End` | (+0.5,+0.5,+0.5) / (−0.5,−0.5,−0.5) | same | same | same | `:17-26` |
| `MoveDirection` | (0,−1,0) | same | same | same | `:27-31` / `0x26B` |
| `WeatherStart/End` | 70 / 100 | 70 / 100 | 70 / 100 | 70 / 100 | `:32-33` / `0x2C3` |
| `MonthStart/End` | 1 / 12 | same | same | same | `:34-35` |
| `Speed` | 0.040999997407198 | 0.0610000006854534 | 0.0800000056624413 | 0.100000001490116 | `:36` / `0x313` |
| `Count` | 100 | 100 | 100 | **200** | `:37` / `0x331` |
| `CameraSpeedFactor` | 0.100000001490116 | same | same | same | `:38` |

`particles.lib:2-14`: `Name = snow`, `Visible/Active = True`, `Width/Height/
Depth = 1`, `Position = (1,2,3)`, `AutoOffsetFromCamera = True` (`0x0C1`),
`ParticleCollectionFileName = .\data\env\pfx\particles.snow.cfg` (`0x0E1`).
`particles.mat:3,29,111,137,219,245,327,353` binds `snow1..4` to the 4 BMPs.

### 5.8 Byte-offset verification and claim cross-checks

| Claim | Method A | Method B |
|---|---|---|
| `source.pfx` = 44 sections, CRLF, no NUL | line parser + `b.count(0)==0`, 2,893 CRLF | Craft Anything `read` of `:1-185`; DEEPDEC-07 §4.2 also counted 44 |
| Section offset 0x2F7 = line 30 | cumulative `len(line)+2` | direct byte re-read → `b'section.begin'` |
| `fx.tree` = 24 effects, 6 inheritance children | line parser (`:4..:522`) | byte re-read at `0x4A` → `b'         effe'` (the `effectname` line, as predicted) |
| `manager.lib` = 5 managers | Python fields | Craft Anything `read` lines 1-37 |
| DDS `musketsmoke` 2048² DXT5, 12 mips | `struct.unpack_from` | hexdump at `0x0` + file-size closure 5,592,560 B |
| `material.mat` = 22 records | Python section parse | Craft Anything `read` `:1-90`, grep for `Name =` |
| `rand*` codes 1..8 = random-slot ids | `fx.tree` values | `pfx.script:12,43-85` consumer (`rand[code-1]`) |
| PFX API strings in EXE | raw `bytes.find` | hexdump excerpt at `0x35DC40`, `0x23C0F0`, `0x2DC8F0` |
| Data keys absent from EXE | raw find of 10 keys (0 hits) | `codex.dll` case-insensitive find (0 hits for PFX/Effect/Particle/smoke) |

---

## 6. Emitter parameters — where each class of value actually lives

The ticket's assumed emitter schema ("rate, lifetime, velocity, gravity…") does
**not** exist as a single record. Verified distribution:

| Parameter | Where it lives | Exact evidence |
|---|---|---|
| size | `PixelRatio` (animatedsprite), `MarkWidth` (trail), `Height`/`Width` (weather) | `source.pfx:51,1746`; `particles.snow.cfg:4-5` |
| lifetime / fade | `AlphaTime`, `AlphaPower`, `Time[0..1]`, `OnEndFrameState/Hide`, `AnimationMode` | `source.pfx:61-62,176,166`; `source.ref:62-99` |
| "rate" / timing | `Interval`, `FrameRate`, `EndFrame`, `CurrentFrame` | `source.pfx:46-47,41`; weather `Speed`, `CameraSpeedFactor` (`:36,38`) |
| velocity / gravity | **no emitter field in `source.pfx`**; engine-set via `InitialVelocity`, `VelocityDispersion`, `Min/MaxExpInitSpeed`, `ExpNumbParticles`, `EffectSourcePFX*` (EXE API, see §9); weather uses `MoveDirection` + `Speed` | raw EXE strings at `0x23C...`, `0x2DC3C6`, `0x2DC41E` |
| count | `ExpNumbParticles` / `MaxParticles` engine-side; weather `Count = 100/200` | EXE RTTI `0x2DB8D9`; `particles.snow.cfg:37,77,117,157` |
| colour | `material.mat` tint + `StartColor/LifeColor/EndColor` defaults (1,1,1,1), `firepalette` texture, `UseLifeColor=False`; Fire manager `InnerColor/OuterColor` | `material.mat:17-37`; `source.ref:55-75`; EXE `0x2DBA49/0x2DBB2D` |
| texture | `LibMaterialName` → `material.mat` → `Texture.image` → DDS/BMP | `source.pfx:44,1280,1750`; `material.mat:13,358,444` |
| blend | `BlendingMode` in material + PFX manager `BlendingMode` API | `material.mat:3,14,111`; EXE `0x2CDF20` region |
| per-layer randomisation | `fx.tree` `rand*` codes consumed by `pfx.script:47-85` | §7.1 |

**Label:** the parameter *fields* above are **observed**; the mapping of
`PixelRatio`/`Interval`/`AlphaTime` to metres or seconds is **UNVERIFIED** — no
consumer converting them was recovered in text, and the EXE carries only API
prototypes, not conversion constants.

---

## 7. Exact FX constants for skirmish-visible effects

### 7.1 Volley smoke (`shotmusket`, 5 layers) — observed data + derived arithmetic

A volley has **no dedicated FX key**: each musket shot independently creates
the same 5-layer `shotmusket` composition (`fx.tree:4-63`); N shooters = N
compositions. Cross-check: no `volley`/`salvo` token in any effect/config file
(grep over donor `data`; only mission text contains the word).

| Constant | Value | Citation | Label |
|---|---|---|---|
| Layer keys | musketsmoke, musketflash, musketsparks, musketsmokeup, musketflashup | `fx.tree:7,26,32,38,49` | observed |
| Smoke `EndFrame` | 127 | `source.pfx:41` (`0x45D`) | observed |
| Smoke frame size / image | 256×128 / 2048×2048 | `source.pfx:42-43,48-49` | observed |
| Smoke `Interval` / `FrameRate` | 10 / 100 | `source.pfx:46-47` | observed |
| Smoke `PixelRatio` (size) | 175 | `source.pfx:51` (`0x571`) | observed |
| Smoke `AlphaTime` / `AlphaPower` | 1.5 / 1.5 | `source.pfx:61-62` (`0x669`) | observed |
| Smoke `OnEndFrameState` | `FreeToPool` | `source.pfx:60` | observed |
| Smoke position | (−0.1, −1.5, 0.775) | `source.pfx:54-57` | observed |
| `randpixelratio` | code **3**, range −25..+25 % | `fx.tree:16-18` (`0x215`,`0x23F`) | observed; code semantics derived from `pfx.script:63-67` |
| `randframerate` | code **2**, range −20..+20 | `fx.tree:13-15` | observed |
| `randposition.y` | code **3**, −0.1..+0.1 | `fx.tree:19-21` | observed |
| `randscale.y` | code **4**, stop +0.05 | `fx.tree:22-23` | observed |
| `randmirroru/v`, `randanimation` | codes 0/1/0 → mirror-V 50 % via `rand[0]`; no animation randomisation | `fx.tree:10-12`; `pfx.script:47-57` | derived (50 % follows `Round(rand)=1`) |
| Up-smoke layer | `PixelRatio` 600, EndFrame 63, `randpixelratio` 0..+50 % | `source.pfx:258-294`; `fx.tree:40-46` | observed |
| Construction/volley material tint | 0.3137255 (80/255) grey | `material.mat:17-37` | observed |
| Shader | 31 (noise alpha) | `manager.lib:26-30`; `fx.id31.frag:43-49` | observed |

### 7.2 Muzzle flash — observed

| Constant | Value | Citation |
|---|---|---|
| 4 single-frame animations (frames 0/1/2/3) | `CurrentFrame/StartFrame/EndFrame = n/n/n` | `source.pfx:112-114,125-127,138-140,151-153` |
| Frame size / image | 256×128 / 512×256 | `source.pfx:115-122` |
| `PixelRatio` | **350** | `source.pfx:167` |
| `Interval` / `FrameRate` | 100 / 10 | `source.pfx:164,169` |
| `AnimationMode` | `samPlayOnce`, `AnimationIndex=0` | `source.pfx:165-166` |
| `OnEndFrameHide` | True (**no** alpha fade) | `source.pfx:176` |
| Position | (−0.1, −1.0, 0.775) | `source.pfx:170-173` |
| Material tint / shader | (1,1,1,1) / 29 | `material.mat:63-81`; `manager.lib:10-14` |
| Layer randomisation | `randanimation=1`, `randmirrorv=2` | `fx.tree:28-29` |

Cannon: `cannonflash` EndFrame 15, `PixelRatio` 450, `Interval` 25 /
`FrameRate` 40 (`:426,431-432,439,441`), `samPlayOnce`, `OnEndFrameHide=True`
(`:437,453`), palette shader 30 + `firepalette` (`material.mat:194-225`).

### 7.3 Arrow and projectile trails — observed

| Constant | `bullettrail` | `fragtrail` | `firearrowtrail` | Citation |
|---|---:|---:|---:|---|
| `VertLimit` | 150 | 150 | 150 | `source.pfx:1739,1776,2312` |
| `TimeLimit` | **0.2** | 0.2 | 0.2 | `source.pfx:1740` (`0xBFA8`), `:1777,2313` |
| `MinDistance` | 0.05 | 0.05 | 0.05 | `:1741,1778,2314` |
| `Alpha` | **0.2** | 0.2 | **0.3** | `:1742,1779,2315` |
| `AlphaFade` / `UVScale` | True / 1 | True / 1 | True / 1 | `:1743-1744,1780-1781,2316-2317` |
| `MarkStyle` | `msFaceCamera` | `msFaceCamera` | `msFaceCamera` | `:1745` (`0xC017`), `:1782,2318` |
| `MarkWidth` | **0.1** | **0.05** | 0.1 | `:1746` (`0xC037`), `:1783,2319` |
| `ZWrite/ZTest` | False/False | False/False | False/False | `:1748-1749,...` |
| `Diffuse` RGBA | (1,1,1,1) | (1,1,1,1) | (1,1,1,1) | `:1759-1763,...` |

Weapon assignment (observed): **all** projectiles including arrows use
`bullettrail` (`weapon.script:281-287`); only `OSTRELA` uses `firearrowtrail`
(`:286,437`); howitzer fragments, wood and stone debris use `fragtrail`
(`:288-290,435,438-439`). Applied on projectile spawn at `weapon.script:981-982`.

### 7.4 Building construction dust — **absent as a distinct FX** (correction)

This is the one requested class with **no donor FX**:
- `units\unit.inc\onaclanimationreachedconstruct.inc:23-43` advances build HP
  and plays **sound only** (`workconstruct` at `:43`); no effect call.
- `objects\units\...` / `materials\buildings\constructor\debris.dds` and
  `materials\pfx\buildfire*_birth.dds` / `buildsmoke*_birth.dds` exist
  (`pfx.mat:6-47`), but **no readable consumer** selects them → UNVERIFIED
  whether the engine's construction/birth animation uses them internally.
- The visible building smoke is **damage smoke**, gated by HP thresholds:
  `building.inc\nothing.inc:40-83` (`smokeHPMaxIntense`, `cSmokeHPLimit`,
  `cProgressSmokeIncrease`); an invisible `point` object is spawned at a
  `smokePoints[i]` position and
  `gEffectLibrary.GetOrCreate('buildingsmoke', effHnd)` at `:78` and `:383`.
  The 4-layer `buildingsmoke` composition is `fx.tree:418-442`; its sources are
  `samPlayOnce` ignition (`:1858`) + `samLoop` sustained fire/smoke
  (`:2049,:2146`), `PixelRatio` 110/138/110/110, `AlphaPower` 1.5
  (`source.pfx:1860,1867,1955,1962,2051,2148,2155`).
- Dust-like ground impacts are `impactdust`: `EndFrame 127`, `PixelRatio 100`,
  `AlphaTime/AlphaPower 2.0/2.0` (`source.pfx:1277,1291,1299-1300`) — used for
  projectile/ground hits, not for construction.

**Label:** ABSENT in readable data; engine-internal birth art UNVERIFIED.

### 7.5 Death / explosion — observed

| Effect | Constant | Citation | Label |
|---|---|---|---|
| Unit death fade (not a PFX) | `EffectCreateWithKey(goHnd,'TXLifeColorEffect','death',false)`; `AlphaChannel[0]=1`, `[1]=0.4`, `BlendingMode=1` (bmTransparency), `Loop=False` | `unit.inc\deathstage1.inc:24,49,64-65,42`; also `deathstage2.inc:55`, `deathstage3.inc:23` | observed |
| Death duration | `time := 2 + time − random*(time/1)` for non-ships/non-artillery | `deathstage1.inc:67-76` | observed |
| Grenade/death explosion key | `cFXGrenadeExp = 'grenadeexp'`, assigned to `PU4GRE`, `PUEXPKORDEATH`, `PUEXPONSHIP`… | `weapon.script:270,374,375,384-390` | observed |
| Cannon ground explosion | `cannonexpground`: EndFrame **255** (two animations), `PixelRatio` **30**, `AlphaTime` **1.2**, `AlphaPower` **1.0**, `FrameRate 83.3333`, `Interval 12`, `MirrorV=True`, `FreeToPool` | `source.pfx:1322,1364,1407,1414-1415,1409,1327,1408,1412` | observed |
| Cannon building explosion | `cannonexpbuilding`: EndFrame 127, PixelRatio 30, AlphaTime/Power 2.0/2.0 | `source.pfx:1556,1570,1579-1580`; `weapon.script:272,368-369` | observed |
| Howitzer explosion | `howitzerexpground/building` inherit `grenadeexp` `[8]` with `randpixelratio` 0..−10 % | `fx.tree:346-359`; `weapon.script:273-274,370-371` | observed |
| Generic building/ship death | `grenadeexp` (4 layers) | `weapon.script:275-276,367,374`; `fx.tree:216-252` | observed |
| Distant flash / ring | `expflash` = distexpflare + distexpring at pixel-ratio −30 % | `fx.tree:398-415`; `unit.script:11509` | observed |
| Framegun explosion | `cFXFramExp = 'framexp'` **has no `fx.tree` record** → `GetOrCreate` returns −1 → no FX | `weapon.script:278`; `pfx.script:353-360` | derived (silent no-op) |
| Explosion decal | `_weapon_CreateDecalExp(...,4,0,20)`, textures `terrain\decals\pfx\groundexp0..3.dds` | `projectile.inc\doexplode.inc:114-118` | observed |

### 7.6 Weather particles — observed, NEW

| Constant | Value | Citation | Label |
|---|---|---|---|
| Default weather value | `Weather = 40` (`WeatherTarget = 40`, `WeatherRandom=False`, range 0..99) | `env\clouds\clouds.weather:3-6,21-22` | observed |
| Snow activation band | `WeatherStart = 70`, `WeatherEnd = 100` for all 4 layers | `particles.snow.cfg:32-33,72-73,112-113,152-153` | observed |
| Consequence for default skirmish | 40 < 70 → **snow inactive** unless weather is raised | derived from the two rows above (assumes same 0..99 scale, supported by `weatherrandomend=99`) | derived / inferred scale |
| Flake size | 0.0015 / 0.002 / 0.00251 / 0.003 (both W and H) | `particles.snow.cfg:4-5,44-45,84-85,124-125` | observed |
| Alpha / blend | `AlphaChannel = 0.5`, `NoZWrite = True`, `btBillboard` | `:6-7,16` | observed |
| Fall direction / speed | `MoveDirection = (0,−1,0)`; `Speed` 0.041 / 0.061 / 0.08 / 0.1 | `:27-31,36,76,116,156` | observed |
| Counts | 100 / 100 / 100 / **200** | `:37,77,117,157` | observed |
| Spiral motion | `SpiralRotatingRadius ≈ 0.1`, `SpiralRotatingSpeed` 20/15/13/13 | `:14-15,54-55,94-95,134-135` | observed |
| Seasons | `MonthStart = 1`, `MonthEnd = 12` (all four) | `:34-35,...` | observed |
| Wind interaction | `WindInteraction=False`, `WeatherInteraction=False`; wind vector (−0.7421,0,−0.8673) in `clouds.weather:7-17` | `:10-11`; `clouds.weather:8-10` | observed (the two are independent knobs) |
| Cloud bands | `clouds.presets` pairs `minweather/maxweather`: 10–50, 50–60, 60–80, 70–99 | `env\clouds\clouds.presets:8-9,62-63,116-117,170-171` | observed |
| Script consumer | **none** — no `weather`/`particle` token in any of the 222 scripts | `DEC_02_scripts.md:865-870`; grep over `data\scripts` (0 hits) | observed |

### 7.7 Selection highlight effects — observed, engine-side

Selection is **not** a PFX: it is `EffectHighlightGetOrCreate` using brush
materials, driven by the selected/picked set each progress tick.

| Constant | Value | Citation |
|---|---|---|
| Render size set at startup | `size := 0.7` in `SetHighlightRenderSettings` | `lib\init.script:106-112` (called `:217`) |
| Material keys | `selection.friend`, `selection.building`, `selection.ship`, `highlight.friend/ally/enemy` | `lib\gui.script:3372-3377` |
| Building size bands | collision-mask mid `mid<5→0`, `<8→1`, `<12→2`, else `3` → `selection.building.[0..3]` | `gui.script:3422-3438` |
| Ship highlight | code commented out; ships fall through to `selection.friend` | `gui.script:3444-3450` |
| Visibility rules | picked + own → selection; own → friend; enemy mask → enemy; else ally; walls and mis-country hidden | `gui.script:3397-3469` |
| Effect call | `EffectHighlightGetOrCreate(goHnd,'h',visible,mat)` | `gui.script:3470` |
| Base `highlight` material | `bmTransparency`, diffuse (1,1,1,0.2) | `brushes\brushes.mat:109-142` |
| Enemy tint / alpha | (1, 0.5647, 0.40392, 0.35) | `brushes.mat:157-164` |
| Friend / ally alpha | 0.3 / 0.35, white | `brushes.mat:166-182` |
| Selected unit | (1, 0.9451, 0.713725, 0.65) | `brushes.mat:199-206` |
| Textures | 13 highlight/selection DDS under `brushes\textures\` | inventory §3.3 |
| User setting | `gc_settings_highlights = True`; settings toggle writes `SetHighlightRenderSettings(...,bbrushunderunit)` | `dmscript.global:1019`; `gui\menu.inc\eventsettings.inc:639-640,754-755` |
| Saved profile keys | `Get/SetHighlightRenderSettings` used in movie/camera restores | `lib\movie.script:140-142,202-205` |

**Label:** materials/keys/constants observed; the final on-screen brush geometry
is generated by the engine effect (`EffectHighlightGetOrCreate`) → UNVERIFIED
visual shape.

---

## 8. Script → effect reference chain (observed)

```
data\scripts\lib\pfx.script:415
  gEffectLibrary.LoadFromFile('.\data\pfx\fx.tree')
      ↓ (parser: effectlibrary[i] → TLibEffects → libeffects[j] → TLibEffect)
data\pfx\fx.tree  (24 effects, 6 refkey children)
      ↓ keyname/sourcename
data\pfx\manager.lib  (PFXType + ShaderID 29/30/31 or pfxTrail)
      ↓ LibSourceID / LibSourceName
data\pfx\source.pfx  (44 source records: animation frames, PixelRatio, alpha)
      ↓ {refurl=source.ref} defaults
data\pfx\material.mat → data\pfx\textures\*.dds/.bmp + shaders\obj\fx.id*.frag
```

Runtime creation paths (exact lines):

| Event | Chain | Citation |
|---|---|---|
| Weapon fire (shot) | unit weapon definition `objprop.weapon[n].fxshot := 'shotmusket'/'shotcannon'/…` → `gWeapons[id].buseownerfxshot` → read `TObjWeaponStatic(...).fxshot` → `gEffectLibrary.GetOrCreate(fxshot, projHnd)` | `unit.script:778,905,950,1233,1552,1583,1596-1644,1709-1836,2162-2231,2547`; `weapon.script:113-118,495-503,994-1004` |
| Generic weapon FX | `gWeapons[id].fx` → `GetOrCreate` (used by virtual explosion/impact weapons `PUEXP`, `SMALL`, `VODABUL`, `PU4GRE`…) | `weapon.script:1008-1015`; registrations `:365-390` |
| Impact / explosion selection | `DoExplode` chooses `explmedia` from target → water → collision tag → decal + `customexplosions[media].list` child weapons | `projectile.inc\doexplode.inc:56,92-118,120-144`; `weapon.script:219-243,573-612` |
| Trails | `weapon.script:427-440` `_weapon_SetWeaponTrail(...)` → `gWeapons[id].trailfx` → `GetOrCreate` on projectile spawn | `weapon.script:73-78,981-982` |
| Building fire smoke | `point` object at `smokePoints[i]` + `GetOrCreate('buildingsmoke', effHnd)` | `building.inc\nothing.inc:67-83,373-386` |
| Distant explosion flash | `gEffectLibrary.GetOrCreate('expflash', hnd)` | `unit.script:11509` |
| Death fade | `TXLifeColorEffect` behaviour 'death' (not `fx.tree`) | `unit.inc\deathstage{1,2,3}.inc` |
| Highlight | `EffectHighlightGetOrCreate` (not `fx.tree`) | `gui.script:3470` |
| Object attachment capability | `PFXProperty` with `EffectsStored` on `point`, `decal`, `fogreveal`, projectile refs, wheel attaches | `objects\misc\point.prop:34-39`; `objects\ref\refproj.prop:43-48`; `objects\ref\refunitattach.prop:106-111` |

**Randomisation (derived from consumer `pfx.script:39-86`):** each layer's
`rand*` integer is a 1-based selector into `rand[0..7]`; 0 disables the
randomisation. Mirror flags use `Round(rand[slot])=1` (≈50 % when the slot
is uniform 0..1); `randanimation` selects
`Round(rand[slot]*(AnimationsCount-1))`; frame-rate/pixel-ratio are additive
`Lerp(start,stop,rand[slot])`; position/scale are additive vector `Lerp`.
When `parentrandom = true` (`fx.tree:217,399,419`) all layers share the same
8 floats (`pfx.script:214-222,239-247`).

---

## 9. Raw-byte search of `cossacks.exe` and `codex.dll` (pass C)

Independent of the Craft Anything string index. Python `bytes.find` over all
5,768,048 bytes of `cossacks.exe` and 106,272 bytes of `codex.dll`,
ASCII and UTF-16LE. Offsets below are **file offsets**, not the VAs used in
DEEPDEC-07 (image-base/section mapping differs); they identify the same RTTI.

| Pattern | Hits in `cossacks.exe` (file offsets) | Meaning |
|---|---|---|
| `GameObjectPFXCreateByHandle` | 1 @ `0x23C11E` | API prototype; hexdump at `0x23C110`: `66 00 00 00 ... "procedure GameObjectPFXCreateByHandle(gohandle: Integer; const managername: String; const key: String)"` |
| `GetOrCreateEffectFXSourceByHandle` | 1 @ `0x22FCE4` | the exact call `pfx.script:41` binds to |
| `EffectHighlightGetOrCreate` | 1 @ `0x2DC8FE` | selection highlight API; hexdump at `0x2DC8F0` shows `function EffectHighlightGetOrCreate(hnd: Integer; key: String; …)` |
| `SetBehaviourFloatProperty` / `SetBehaviourBoolProperty` | `0x2D9AAE` / `0x2D99E6` | script→behaviour setters used by `pfx.script`/death stages |
| `EffectSourcePFXBurst` / `EffectSourcePFXIsotropicExplosion` | `0x2DC3C6` / `0x2DC41E` | emitter primitives (with `mininitialspeed, maxinitialspeed, nbparticles`) |
| `GetOrCreatePFXManager`, `PFXManager` | 1 @ `0x2DA1FA`, 58 total | manager API family; DEEPDEC-07 §2 lists the same RTTI at VAs |
| `TXPFXType` + ten `pfx*` names | `0x35DC4A`, names `0x35DC61..0x35DD9C` (two tables: `0x35DC60` length-prefixed; `0x35DCE0` with `FF FF FF FF` separators) | 10-kind enum in Delphi RTTI order: None, Perlin, Fire, Tracer, Thor, Fountain, Trail, Atmosphere, Sprite, AnimatedSprite |
| `AlphaTime` / `PixelRatio` / `TimeLimit` / `MarkStyle` | 10 / 5 / 5 / 6 hits, e.g. `0x3EBB19`, `0x3EB54C`, `0x400EE3`, `0x400D2B` | field-name strings (RTTI), **not** numeric defaults |
| `InnerColor` / `OuterColor` / `MaxParticles` / `ParticleInterval` | 11 / 11 / 9 / 12 hits, e.g. `0x2DBA49`, `0x2DBB2D`, `0x2DB8D9`, `0x2DC1B1` | fire/perlin manager attributes exist in CODE |
| `musketsmoke`, `bullettrail`, `impactdust`, `shotmusket`, `buildingsmoke`, `framexp`, `source.pfx`, `fx.tree`, `particles.snow.cfg`, `randpixelratio` | **0 hits each** (ASCII and UTF-16LE) | confirms every effect *key* and every numeric default is external data; string-index absence of these is genuine, not an indexing artefact |

Hex excerpt of the enum table (`data` is `cossacks.exe` at `C:\Games\Cossacks 3\`):
```
cossacks.exe:0x35DC40  90 00 01 c3 48 e8 75 00 03 09 54 58 50 46 58 54
                       79 70 65 01 00 00 00 00 09 00 00 00 44 e8 75 00
cossacks.exe:0x35DC60  07 70 66 78 4e 6f 6e 65 09 70 66 78 50 65 72 6c ...
                       ; length-prefixed "pfxNone","pfxPerlin","pfxFire",...
cossacks.exe:0x35DCE0  70 66 78 4e 6f 6e 65 00 ff ff ff ff 09 00 00 00
                       ; second (value-list) table
```

**Numeric tables:** none found. The EXE carries API/field *names* and type
metadata only; no `PixelRatio=175`-style constant table exists in raw bytes.
Any engine-side interpolation (frame→seconds, pixel ratio→world size, burst
count/velocity defaults) is **UNVERIFIED**. `codex.dll` contains **zero**
case-insensitive hits for `PFX`, `Effect`, `Particle`, `smoke`, `AnimatedSprite`
— it is not part of the FX pipeline.

---

## 10. Port comparison (read-only; no changes proposed)

### 10.1 `variant3d/scripts/world3d_fx.gd` (986 lines, read in full)

| Donor feature | Port state | Evidence |
|---|---|---|
| Shot FX (5 layers: smoke + flash + sparks + up-smoke + up-flash) | **APPROXIMATED** — one emissive `SphereMesh` + `OmniLight3D`; no layers | donor `fx.tree:4-63`; port `:630-636` |
| `PixelRatio`/noise shader 31 smoke | **APPROXIMATED** — two crossed `PlaneMesh` quads rising/scaling; tint `Color(0.85,0.85,0.82,0.55)`; life 1.6 s from port `world.gd`, not donor | `source.pfx:41-62`; `material.mat:12-39`; port `:58-69,637-641,850-853` |
| Muzzle flash (4 frames, `samPlayOnce`, hide on end) | **APPROXIMATED** — sphere+light, `shot` life 0.35 s | `source.pfx:102-176`; port `:59,630-636` |
| Palette shader 30 / `firepalette` 256×4 DXT1 | **ABSENT** — no palette texture or random-uniform sampling in port | `fx.id30.frag:26-33`; `material.mat:199,229,291,392,453` |
| Per-layer `rand*` (mirror/animation/frame-rate/pixel-ratio/position/scale), `parentrandom` | **ABSENT** — port has no RNG at all; drift uses `sin(age*f+index)` | `pfx.script:39-86`; port header `:31`, `_update_fx:838-879` |
| `bullettrail` (`TimeLimit 0.2`, `Alpha 0.2`, `MarkWidth 0.1`, `msFaceCamera`) | **PARTIAL** — two constants quoted literally (`TRAIL_TIME_LIMIT`, `TRAIL_ALPHA`, `TRAIL_WIDTH_M`) but visual is a solid `BoxMesh` (no camera-facing strip); streak 1.2 m is a port value | `source.pfx:1739-1759`; port `:73-91,675-678,882-901` |
| `firearrowtrail` (alpha 0.3) / `fragtrail` (width 0.05) | **ABSENT** — one generic `trail` kind, alpha 0.2 | `source.pfx:1776-1783,2312-2319`; port `:88-90,617-618` |
| Impact dust/smoke (`impactdust`, `impactsmoke`, `waterblast*`) | **ABSENT** — port `EVENT_FX` forwards shot/smoke/heal/rout/crater/explode/chop/fire/capture only; impacts have audio, no visual | `weapon.script:264-267`; port `:112-116` |
| Explosion (`cannonexp` EndFrame 255/AlphaTime 1.2; `grenadeexp` 4 layers; `expflash`) | **APPROXIMATED** — sphere + light, life 0.8 s; no ring/flash layers | `source.pfx:1310-1425`; `fx.tree:216-252,398-415`; port `:61,642-648` |
| Building fire/smoke 4 layers, `samLoop` | **APPROXIMATED** — `fire` = crossed quads + flicker light; no start/layers, no `buildingsmoke` binding | `fx.tree:418-442`; `building.inc\nothing.inc:78,383`; port `:655-661` |
| Death `TXLifeColorEffect` fade (alpha 1→0.4, `bmTransparency`) | **ABSENT** — no death FX kind; `deathstage*` not consumed | `unit.inc\deathstage1.inc:24,49,64-65`; port `:112-116` |
| Weather snow 4 layers (Speed/Count/weather band) | **ABSENT** — no particle/weather system in module | `particles.snow.cfg:2-158`; port (no weather code) |
| Selection highlight (`EffectHighlightGetOrCreate`, brush ring materials, size 0.7) | **APPROXIMATED** — procedural `TorusMesh` ring + under-ring + owner pip from donor key-colour JSON; explicitly `PORT APPROXIMATION — NOT DONOR PARITY` | `gui.script:3372-3470`; `init.script:111`; port `:35-49,736-833` |
| PFX object attachment (`PFXProperty`, `EffectsStored`) | **ABSENT** — port FX are free-standing `Node3D` holders, no object-attached behaviour pool | `objects\ref\refproj.prop:43-48`; port `:320-333` |
| FX cap / pooling | **PORT-ONLY** — `FX_CAP=220` (`data.gd:117`), queue-free; donor uses `gEffectLibrary` + `FreeToPool` behaviour | `pfx.script:353-415`; port `:71,934-951` |
| Coordinate origin (V7-73) | **PRESENT / PORT** — `world_offset` derived from `MAP_W/MAP_H*0.5*TILE_M`; no donor analogue | port `:124-127,194-217,462-471`; V773 §4 |

### 10.2 `variant3d/scripts/anim3d.gd` (962 lines, read in full)

`anim3d.gd` implements **no FX/particles**: it samples donor `.oss` skin poses
at donor AAF frames (30 fps) with an explicit `BLOCKED_RIG` /
`PORT APPROXIMATION — NOT DONOR PARITY` label (`:59-66,210-290,410-459`).
Its only overlap with this ticket is the **shot mesh** family
(`data\actors\pfx\shot\shotmusket{1,2}.oss/.aaf`, DEC-04 §5): those could be
used as a pose source but the module does not register them (it registers unit
skins from `assets/models/skin/index.json`, `:110-124,742-888`). No PFX
sprite, trail, weather, impact or highlight behaviour exists there.

### 10.3 Water glints (scope boundary)

`water_glints.md:21-47` proves donor glints are analytic specular terms in
`water.dev.frag` (exponents 170/120, grey `0.4`), **not** a particle effect;
the port's `water_overlay.gdshader:69-75` `×8/×4` and constant-light defects
are a separate shader issue. There is no `pfx` key for glints — do not map
`waterblast` (impact splash) to glints.

---

## 11. Corrections to prior docs

1. **PFX is readable text, not an undecodable binary.** Earlier framing that
   `.pfx` behaviour is BLOCKED/UNVERIFIED is too broad: the full schema, 44
   sources, 24 effects, 5 managers, 22 materials and the consumer logic are
   readable. What remains UNVERIFIED is *unit conversion* and *visual output*,
   not the definitions.
2. **`rand*` randomisation is decoded** (`pfx.script:12,43-85`): values are
   1-based slots into an 8-float random array; 0 = off. V715 `:48-65` and
   DEEPDEC-07 §3's "per-layer randomisation ±25 %" are now backed by the exact
   consumer and code semantics (derived 50 % mirror probability).
3. **Weather is not absent from donor data.** DEC-02 D-14 `:865-870` is correct
   that no script token exists, but `env\pfx\particles.snow.cfg` has four fully
   specified emitters; with default `Weather=40` below the 70–100 snow band,
   snow is inactive by default (derived).
4. **All 24 `fx.tree` effects expanded**, including the six `{refkey}`
   inheritance children that DEEPDEC-07 §8 left unexpanded: `[1] shotmusketcav`,
   `[2] shotmusketking`, `[3] shotmusketdrag`, `[7] shotmcannon`,
   `[13] howitzerexpground`, `[14] howitzerexpbuilding` (§5.2 table).
5. **`framexp`, `arrow`, `firearrow` and `standingsmoke` have no `fx.tree`
   record.** `framexp` is registered as a weapon FX (`weapon.script:278`) but
   `GetOrCreate` returns −1 for unknown keys (`pfx.script:353-360`) → silent
   no-op. This refines DEEPDEC-07's "keys are data, not code".
6. **Material sharing** explains apparent mismatches: `cannonsmoke` →
   `musketsmoke` material, `impactdust` → `impactsmoke`, trails →
   `bullettrail`. Do not "correct" these when porting.
7. **No construction-dust FX exists** in readable data; construction hits are
   sound-only (`onaclanimationreachedconstruct.inc:42-43`). The visible smoke
   is damage smoke (`building.inc\nothing.inc:40-83,373-386`).
8. **Selection is engine-side**, via `EffectHighlightGetOrCreate` + brush
   materials, not a PFX; V715's procedural torus is an approximation of a
   different subsystem.
9. **DEEPDEC-07 §5.1's "327 declared vs 325 oggs"** was already corrected by
   DEC-04 §8.2 (two empty template `Path = ` lines). This report does not
   revive that discrepancy.
10. **Water glints are shader, not PFX**; don't add a fake glint particle key.

---

## 12. Open questions (UNVERIFIED)

1. **Unit conversion** of `PixelRatio`, `Interval`, `FrameRate`, `AlphaTime`,
   `AlphaPower`, `TimeLimit`, weather `Speed`/`Height`/`Width` to pixels,
   metres or seconds. No consumer conversion was recovered in text or raw EXE
   bytes. Derived example (labelled UNVERIFIED): 128 smoke frames at
   `FrameRate=100` ≈ 1.28 engine time units, close to `AlphaTime=1.5` but not
   identical — do not encode either as seconds without an A/B.
2. **Engine interpolation**: how `EffectSourcePFXBurst` /
   `IsotropicExplosion` choose count, initial speed and lifespan; how
   `PFXManager.BlendingMode`, `InnerColor/OuterColor`, `MaxParticles` are
   applied to a `fx.tree` layer. RTTI names exist; numeric defaults do not.
3. **`source.pfx` keys with no effect record** (`standingsmoke`, plus
   `firearrow`/`arrow` as effect keys): dead data, or engine-direct consumers
   not reachable from scripts? No readable call found.
4. **Weather binding**: `env.cfg:18` loads `clouds.weather`; what loads
   `env\pfx\particles.lib` and how the 0..99 weather value gates 70..100 are
   engine-side (no script token).
5. **`buildfire*_birth` / `buildsmoke*_birth` / constructor `debris.dds`**
   materials are named but have no readable selector; engine-internal birth FX
   UNVERIFIED.
6. **Selection brush geometry**: only material keys, tints, alpha and the
   `size=0.7` render setting are readable; the rendered brush mesh/texture
   projection is engine-side.
7. **Enum ordinals** of the ten `pfx*` kinds: string order in RTTI is observed;
   the integer mapping is inferred from Delphi enum ordering, not proven by a
   numeric table.
8. **Visual parity**: no donor GPU capture was made; all appearance statements
   remain UNVERIFIED. No port change is proposed in this ticket.

---

## 13. Summary

| Format | Magic / version | Layout status | Key numbers |
|---|---|---|---|
| `.pfx` | `section.begin` ASCII at `0x0` (or after `{refurl=...}`); **no version**; CRLF, 0 NUL | 44 records fully mapped with byte offsets | IDs 0–43; `musketsmoke` EndFrame 127 / PixelRatio 175 / AlphaTime 1.5 |
| `.tree` | `section.begin` | 24 effects, 6 `refkey` children, all layers expanded | `shotmusket` 5 layers; ±25 % pixel-ratio via rand code 3 |
| `.lib` (PFX managers) | `section.begin` | 5 managers | 4 × `pfxAnimatedSprite` (ShaderID −2/29/30/31) + 1 × `pfxTrail` |
| `.mat`/`.ref` | `section.begin` | 22 materials + 1 template; blend/tint/texture mapped | smoke tint 80/255; `bmTransparency`; palette texture 256×4 |
| DDS / BMP | `DDS ` at `0x0`, 124-B header, no version field | header fully decoded; 90 FX DDS + 6 BMP | DXT1/DXT5, up to 2048², 12 mips |
| env weather `.cfg`/`.lib` | `section.begin` | **4 emitter records fully mapped** (new) | Count 100/100/100/200; Speed 0.041–0.1; Weather 70–100 |
| `.prop` | `{refurl=...}` + section | `PFXProperty` / `EffectsStored` capability recorded | 8 projectile/debris props |
| `cossacks.exe` | PE; API strings CODE-resident | raw find + hexdump, two ways | 10-kind `TXPFXType` at file `0x35DC4A`; 0 data-key hits; **no numeric tables** |
| `codex.dll` | — | 0 FX strings | not in FX pipeline |

**Bottom line.** Donor FX definitions are *data-complete and text-readable*;
the missing piece was never a packed binary format but the *engine-side meaning*
of a handful of numeric fields and the existence of a separate weather-particle
family. For skirmish, the highest-value exact constants are now cited:
volley smoke (`fx.tree:4-63`, `source.pfx:30-64`), muzzle flash
(`source.pfx:102-178`), all trails (`source.pfx:1731-1803,2304-2339`),
impact/explosion keys (`weapon.script:263-290,365-390`), weather
(`particles.snow.cfg:2-158`) and selection (`gui.script:3372-3470`,
`brushes.mat:109-240`). The port implements procedural stand-ins only; no
donor-parity claim is made and no code was changed.

---
*DFX-01, 2026-11-25. Read-only donor recon. No donor executable run, no donor
bytes copied into the repo, no code edits, no runner jobs. Every donor fact
cites a path:line or path:offset; uncertainties are labelled UNVERIFIED.*
