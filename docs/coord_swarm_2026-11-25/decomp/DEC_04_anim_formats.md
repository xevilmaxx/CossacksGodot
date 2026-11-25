---
title: DEC-04 — Donor animation & sound binary formats, deeply documented (.oss, .osm, .aaf, ACL, audio)
owner: DEC-04 (decompilation micro-worker, 2026-11-25 lane)
date: 2026-11-25
mode: "read-only donor recon; Python bytes/struct/latin-1 + Craft Anything read tools only"
donor: "C:\Games\Cossacks 3 (READ-ONLY; no donor binary run or copy)"
governing_rule: "docs/coord_swarm_2026-11-25/decomp/README.md:16-28 — cite donor path:offset or evidence id; separate observed / derived / inferred / UNVERIFIED; verify each layout claim two ways"
evidence_ids: "see §10 Evidence index; Craft Anything findings fnd_1..fnd_6 (this lane)"
status: "COMPLETE — documentation only; no code edits, no donor copies"
---

# DEC-04 — Donor animation & sound binary formats, deeply documented

## 0. Goal

Document the installed donor's animation and audio formats **as evidence** so that
every skinned-mesh, rig, clip-timing and audio-container decision in the Godot 4.x
port can cite a donor path + byte offset or a stable evidence id. Specifically:

1. Give complete, byte-offset-level layouts for `.oss`, `.osm`, `.aaf`, ACL and the
   shipped audio containers (`.snd`/`.slc` manifests + `.ogg` payload), including
   magic/version, field sizes, record counts, string tables, alignment, endianness
   and iteration recipes.
2. Establish what is **actually readable** about bone hierarchy/parent indices,
   morph targets, action frame ranges and FPS — verifying/refuting/refining the
   prior docs (`V72`, `DEEPDEC-06`, `V764`, `ANIM_ADJUDICATION`, `ANIM_ATTACK`, …).
3. Separate what blocks a faithful skin/rig port from what is merely unverified
   visually.

All facts are labelled **observed** (bytes actually read), **derived** (computed
from observations), **inferred** (best explanation) or **UNVERIFIED** (absent or
not provable from read-only data). Every important structural claim is checked
two ways (direct struct read + whole-family size closure, or two independent
tools/offsets). All donor paths are relative to `C:\Games\C3` unless stated.

---

## 1. Prior docs read (all read first, read-only)

| # | Source | What it supplied / where this report extends or corrects it |
|---|---|---|
| P1 | `docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md` | §3.2 `.oss` header table + exact size closure; §3.3 "bone parent hierarchy unreadable" (Table B1); §4.3 skinned-GLB BLOCKED. **Extended** with full layouts; **refined** in §6. |
| P2 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_06_models_anim.md` | F1–F10: size closure 335/335, 7-float record, "frame 0 = exact bind pose for every bone", "absolute deltas", no bone names. **F4/F5 substantially corrected** in §6 (frame 0 is NOT bind for multi-bone files). |
| P3 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_07_fx_audio.md` | RTTI of sound/PFX APIs, `.snd` schema, grid aggregation, radii 25/50/75/100, winmm waveOut. §8 of this report adds **container-level** byte evidence. |
| P4 | `docs/audit/ANIM_ADJUDICATION.md` | AAF cadence bands, `duration=(last-first+1)/fps` at 30 fps, 299/299 metrics re-measured. Used as the timing authority. |
| P5 | `docs/audit/ANIM_ATTACK.md` | 51/51 attack durations donor-exact from AAF; `loop=false` attacks; 12-frame decimation. Used in §4.3/§5. |
| P6 | `docs/decomp/DE_AUDIO_UI.md` | 325 `.ogg` / 3 `.snd`, 20 missing nation tracks, "327 declared paths vs 325 oggs". **The 2-path discrepancy is resolved** in §8.2. |
| P7 | `docs/decomp/DC_FORMATS.md` | Family census; §2.1 `.oss`, §2.2 `.osm`, §2.3 AAF/ACL dialect; `.osm` offset verdict. **Extended** with full field/offset tables and a 3,897-file census; **refined** at §4.2/§6. |
| P8 | `investigation.cany/investigation/findings.md`, `hypotheses.md` | fnd_1 (26.666 px/m, 32 fps movement clock), fnd_4 (packed loader); hyp_1 (rules live in data/scripts, not EXE code). Confirms why text/byte recon is the right method here. |
| P9 | `docs/coord_swarm_2026-11-24/reports/V764_donor_morph_anim.md` | Donor-sampled flat-root morph data, `skin_vertices(ref_frame=-1)`, 17/17 runner checks, `BLOCKED_RIG`, visual UNVERIFIED. Corrected at §6.3/§7. |
| P10 | `docs/coord_swarm_2026-11-24/reports/V774_consume_poses.md`, `V778_ship_skins.md`, `AUDIT3D_TRIAGE.md:36`, `COMPLETENESS_06_verdict.md:36` | The "733/733 verts changed" claim. **Resolved** in §6.4: 733 is the OBJ `vt` / de-indexed corner count, not `.oss` vertex count. |
| P11 | `docs/coord_swarm_2026-11-25/decomp/README.md` | Lane rules; the reason for evidence ids and two-way verification. |

Craft Anything evidence ids from P2/P7 were reused where the same files were
triaged (`peaukr.oss` `ev_cd615ee5…`, `spruce1.osm` `ev_d77efe75…`,
`algcen.osm` `ev_b99b4a21…`); new byte-pattern searches produced the additional
ids listed in §10. Six consolidated findings were recorded into the shared
Craft Anything investigation as `fnd_1..fnd_6` (revision 6).

---

## 2. File samples

All samples are read-only, private-use donor files; sizes from
`os.path.getsize`. Census counts from recursive `glob` over `data\`.

| Format | Sample path | Bytes | Role |
|---|---|---:|---|
| `.oss` | `data\actors\units\peaukr.oss` | 312,376 | 20-bone Ukrainian peasant, 483-frame timeline |
| `.oss` | `data\actors\units\pikeman.oss` | 225,352 | 20-bone pikeman, 733 verts |
| `.oss` | `data\actors\units\yacht.oss` | 217,344 | 20-bone naval crew/hull attachment |
| `.oss` | `data\actors\buildings\aus\attach\ausbaranim.oss` | 16,528 | 10-bone building-animation attach |
| `.oss` | `data\actors\pfx\shot\shotmusket1.oss` | 3,148 | 1-bone FX shot mesh |
| `.osm` | `data\actors\env\spruce1.osm` | 60,300 | static spruce; **extra vertex frame** |
| `.osm` | `data\actors\buildings\alg\algcen.osm` | 224,412 | static building; exact closure |
| `.osm` | `data\actors\units\yacht.osm` | 427,436 | ship hull; exact closure |
| `.aaf` | `data\animations\aaf\peaukr.aaf` | 455 | 18 named actions |
| `.aaf` | `data\animations\aaf\cannon.aaf` | 97 | static `idle 1..1` |
| `.acl` | `data\animations\acl\cannon.acl` | 2,820 | 19 nested structs; refkey chain |
| `.acl` | `data\animations\acl\yacht.acl` | 1,790 | naval clip list |
| `.acl` | `data\animations\ref\refunit.acl`, `refspeed.acl` | 1,341 / 4,428 | inherited templates |
| audio | `data\sounds\sounds.slc` | 310 | 3-library manifest |
| audio | `data\sounds\units\units.snd` | 30,635 | 247 clip records (248 `Path` lines incl. empty template) |
| audio | `data\sounds\units\musket1.ogg` | 266,576 | Ogg Vorbis, 56 pages |

**Family census (observed, this pass):** `.oss` **335**, `.osm` **3,897**,
`.aaf` **246**, `.acl` **30**, `.ogg` **325**, `.snd` **3**, `.slc` **1**.
These independently reproduce P1 §3.1 and P7 §1.

---

## 3. Verification method (two ways per claim)

| Claim class | Method A | Method B (independent) |
|---|---|---|
| `.oss` header counts / section offsets | `struct.unpack_from('<6i', b, 0)` + sequential section reads at computed offsets | Whole-family **exact size closure** over all 335 files: `24 + v·12 + fc·12 + t·8 + fc·12 + Σ_v(4+8·n_i) + b·k·28 == filesize` (335/335 pass) |
| `.oss` no parent table | 335/335 closure leaves **0 slack bytes**; zero `bone`/`parent`/`skel` ASCII hits; zero strict ASCII runs ≥8 chars | Craft Anything whole-file `native_bytes_find` for `bone` = 0 matches in prior pass (`DEEPDEC-06` E7); weight-list iteration consumes exactly `v` lists |
| `.osm` magic/version/offsets | 68-byte header read on 3 samples, hexdumps at `0x0`, `0x44`, `of` | 3,897/3,897 magic `IDP2` + version 8; arithmetic `ou+nu·8=ot`, `ot+nt·24=of`, `of+16+nv·16≤filesize` on every file |
| `.aaf` row format | direct CRLF line parse + hexdump | 246/246 files parse; line-2 count equals row count; 1,434/1,434 rows match the regex `"name",start,end,flag` |
| ACL dialect | byte hexdump + `struct.begin`/`struct.end` balance on `cannon.acl` (19/19) | 30/30 files contain `section.begin`/`section.end`; refkey targets `refunit.acl`/`refspeed.acl` confirmed to exist |
| Ogg/Vorbis | page-by-page walk of `musket1.ogg` (header bytes, segment tables, granule positions) | 325/325 files begin `OggS`, first packet `01 76 6f 72 62 69 73`, parseable ID header |

---

## 4. Per-format binary layout tables

### 4.1 `.oss` — skinned animated mesh (**fully decoded**)

**Magic/version: NONE.** The first four bytes are `k` (frames per bone), not a
signature; files cannot be identified by magic. **Endianness: little** (all ints
and float32). **Alignment: tight 4-byte** — every section start is a multiple of 4;
there is no padding.

**24-byte header at `0x0`** — `<6i`:

| Off | Size | Field | Meaning | `peaukr` | `pikeman` | `yacht` | `ausbaranim` | `shotmusket1` |
|---:|---:|---|---|---:|---:|---:|---:|---:|
| 0 | 4 | `k` | frames per bone | 483 | 312 | 311 | 43 | 91 |
| 4 | 4 | `fps` | frames per second (**30 in all 335**) | 30 | 30 | 30 | 30 | 30 |
| 8 | 4 | `b` | bones | 20 | 20 | 20 | 10 | 1 |
| 12 | 4 | `v` | vertices | 577 | 733 | 584 | 81 | 8 |
| 16 | 4 | `fc` | triangles (face triples) | 921 | 1062 | 947 | 78 | 12 |
| 20 | 4 | `t` | UVs | 733 | 939 | 793 | 81 | 12 |

**Section layout** (offsets computed cumulatively; all observed):

| Section | Start (peaukr) | Record | Count | Bytes | Iteration |
|---|---:|---|---:|---:|---|
| header | 0 | `<6i` | 1 | 24 | one read |
| vertices | 24 (`0x18`) | `<3f` xyz | `v` | `v·12` | sequential |
| faces | 6948 (`0x1b24`) | `<3i` vertex indices | `fc` | `fc·12` | sequential |
| UVs | 18000 (`0x4650`) | `<2f` uv | `t` | `t·8` | sequential |
| UV-faces | 23864 (`0x5d18`) | `<3i` UV indices | `fc` | `fc·12` | sequential |
| weights | 34916 (`0x8864`) | `<i count>` then `count × <i f>` (bone index, weight) | `v` lists | `Σ(4+8·nᵢ)` | **iterate all `v` lists; do not read only the first count** |
| bone tracks | 41896 (`0xa3a8`) | `<7f` = `px,py,pz,qx,qy,qz,qw` | `b·k` | `b·k·28` | **bone-major**: `anim[bone][frame]` |

**Cross-checks (observed/derived):**
- `peaukr`: 584 weight pairs, counts `{1:573, 2:1, 3:3}`, every vertex-weight sum
  exactly `1.0`, bone indices in `0..19` (= `b−1`), all 20 bones referenced.
- Closure `24 + 577·12 + 921·12 + 733·8 + 921·12 + (6980) + 20·483·28 = 312,376`
  = on-disk size, **tail 0**. Same for `pikeman` (225,352), `yacht` (217,344),
  `ausbaranim` (16,528), `shotmusket1` (3,148): **335/335 exact closure, 0 failures**.
- Quaternion norm sampled over 8 frames × all bones of all 335 files:
  `0.9999999169 .. 1.0000001079` — the last 4 floats are unit quaternions, not
  arbitrary integers. No float slot is a stable parent index (see §6.1).

**Short hexdumps (`path:offset`):**

```
data\actors\units\peaukr.oss:0x0000   e3 01 00 00 1e 00 00 00 14 00 00 00
                                     41 02 00 00 99 03 00 00 dd 02 00 00
        ; = k=483, fps=30, b=20, v=577, fc=921, t=733
data\actors\units\peaukr.oss:0x8864   01 00 00 00 0d 00 00 00 00 00 80 3f
                                     01 00 00 00 0d 00 00 00 00 00 80 3f
        ; weight list: count=1, bone=13, weight=1.0 (repeated)
data\actors\units\peaukr.oss:0xa3a8   00 00 80 b0 a0 35 3c af 00 00 00 00
                                     00 00 04 1e 00 00 80 2f 00 00 fc 2d
                                     00 00 80 3f
        ; bone0 frame0 <7f> ≈ (0,0,0, 0,0,0,1)
data\actors\units\pikeman.oss:0x0000 38 01 00 00 1e 00 00 00 14 00 00 00
                                     dd 02 00 00 26 04 00 00 ab 03 00 00
        ; k=312, fps=30, b=20, v=733, fc=1062, t=939
data\actors\buildings\aus\attach\ausbaranim.oss:0x0000
                                     2b 00 00 00 1e 00 00 00 0a 00 00 00
                                     51 00 00 00 4e 00 00 00 51 00 00 00
        ; k=43, fps=30, b=10, v=81, fc=78, t=81
```

**Family census (observed):** fps = 30 in **335/335**; `b` distribution
`{1:124, 2:5, 3:6, 4:7, 5:8, 7:15, 8:3, 9:4, 10:1, 13:23, 15:2, 16:11, 17:7,
18:7, 19:6, 20:22, 21:16, 22:15, 23:7, 24:43, 27:1, 42:2}`; `k` range 24..755;
109 files have at least one vertex with >1 weight pair.

### 4.2 `.osm` — static mesh (MD2-style, IDP2)

**Magic/version: observed** `IDP2` = bytes `49 44 50 32` = little-endian int
`0x32504449`; version int = **8** at `0x4`. All 3,897 files agree.
**Endianness: little**; **alignment: 4-byte** (all section offsets multiples of 4).

**68-byte header — 17 `<i`** (field indices 0-based, as in P7 §2.2):

| Idx | Off | Name | `spruce1` | `algcen` | `yacht.osm` | Meaning |
|---:|---:|---|---:|---:|---:|---|
| 0 | 0x00 | magic | 844121161 | same | same | `"IDP2"` LE |
| 1 | 0x04 | version | 8 | 8 | 8 | MD2-style version |
| 2–3 | 0x08 | `sw,sh` | 256,256 | 256,256 | 256,256 | skin dimensions |
| 4 | 0x10 | `fs` | 13824 | 78432 | 149840 | section-size hint |
| 5 | 0x14 | `ns` | 1 | 1 | 1 | count of 64-byte section records |
| 6–8 | 0x18 | `nv,nu,nt` | 863,887,1060 | 4901,5256,4325 | 9364,11490,7731 | counts |
| 9–10 | 0x24 | `ng,nf` | 0,1 | 0,1 | 0,1 | gl-command count / frame-ish flag |
| 11 | 0x2c | `os` | 68 | 68 | 68 | section start (header ends here) |
| **12** | 0x30 | **`ou`** | 132 | 132 | 132 | UV offset |
| **13** | 0x34 | **`ot`** | 7228 | 42180 | 92052 | triangle offset |
| **14** | 0x38 | **`of`** | 32668 | 145980 | 277596 | vertex-frame offset |
| 15 | 0x3c | `og` | 46492 | 224412 | 427436 | group/end-ish offset |
| 16 | 0x40 | `oe` | 46492 | 224412 | 427436 | end offset |

**String table — observed:** the `ns × 64`-byte section at `os`=`68` starts at
`0x44` with `SkinBitMap::::::::…` — a fixed-width 64-byte name field (11 ASCII
chars + 53 `0x3a` colons). Each vertex frame begins with another fixed 16-byte
ASCII header at `of`: `FRAME 000........\0` (6 chars + 9 dots + NUL). No other
ASCII tables exist.

**Section bodies:**

| Region | Start | Record | Count | Bytes |
|---|---:|---|---:|---:|
| section name | `os`=68 | 64-byte char field | `ns`=1 | 64 |
| UVs | `ou`=132 | `<2f>` | `nu` | `nu·8` |
| triangles | `ot` | `<6i>` = 3 vertex + 3 UV indices | `nt` | `nt·24` |
| frame header | `of` | 16 ASCII bytes `FRAME …\0` | 1 | 16 |
| vertices | `of+16` | `<3f I>` = xyz + uint32 attr/normal word | `nv` | `nv·16` |

Triangles are consumed with the winding swap `(0,2,1)` on **both** index triples
(P7 §2.2). Arithmetic closure (observed on all samples and all 3,897 files):
`ou + nu·8 = ot`; `ot + nt·24 = of`; `of + 16 + nv·16 ≤ filesize`.

**Short hexdumps (`path:offset`):**

```
data\actors\env\spruce1.osm:0x0000  49 44 50 32 08 00 00 00 00 01 00 00
                                    01 00 00 00 00 36 00 00 01 00 00 00
       ; IDP2, version 8, sw=256, sh=256, fs=13824, ns=1
data\actors\env\spruce1.osm:0x002c  44 00 00 00 84 00 00 00 3c 1c 00 00
                                    9c 7f 00 00 9c b5 00 00 9c b5 00 00
       ; os=68, ou=132, ot=7228, of=32668, og=oe=46492
data\actors\env\spruce1.osm:0x0044  53 6b 69 6e 42 69 74 4d 61 70 3a 3a
                                    3a 3a 3a 3a 3a 3a 3a 3a 3a 3a 3a 3a
       ; "SkinBitMap::::::::... "
data\actors\env\spruce1.osm:0x7f9c  46 52 41 4d 45 20 30 30 30 2e 2e 2e
                                    2e 2e 2e 00 1a 5f 27 3e 15 00 45 3e
                                    02 3d 02 bd 01 00 00 00
       ; "FRAME 000........\0" then first <3f I> vertex
       ; = (0.16345, 0.19238, -0.03180, attr=1)
```

**Census (observed):** magic `IDP2` and version 8 in 3,897/3,897; `ng=0` in
3,897/3,897; `nf=1` in 3,868 files, `nf>1` in 29 (max 307, e.g. some env/ship
meshes). **3,767** files close exactly at `of+16+nv·16`; **130** carry extra
16-byte vertex records beyond `oe` (of these, 29 have `nf>1` and 101 have
`nf=1`). `spruce1.osm` is one of the latter: extra =
`60,300 − 46,492 = 13,808 = 863·16` = exactly one additional un-headered vertex
frame — a **refinement** of P7 §2.2's "all end offsets equal file size".

### 4.3 `.aaf` — named action ranges (ASCII)

**Magic: observed** `"AAF"` at byte 0 (`41 41 46`); **no version field** — the
second line is the decimal record count. CRLF line endings (`0d 0a`); ASCII.

Layout:

| Byte offset (peaukr) | Field | Type | Meaning |
|---:|---|---|---|
| `0x0` | magic | 3 ASCII bytes | `AAF` |
| `0x3` | EOL | 2 bytes | CRLF |
| `0x5` | count | ASCII decimal + CRLF | number of action rows (18) |
| `0x8`… | rows | `"name",first,last,morph` + CRLF | inclusive frame bounds |

`first,last` are **inclusive 1-based donor frames**; the literal flag `morph` is
present on every row in all 246 files (1,434 rows total). Duration recipe
(derived, cross-checked by P4/P5): `duration = (last − first + 1) / 30` seconds,
where 30 is the paired `.oss` `fps`. The port's 12-frame bake is a decimation of
this range, not the donor cadence.

**Short hexdump (`path:offset`):**

```
data\animations\aaf\peaukr.aaf:0x0000  41 41 46 0d 0a 31 38 0d 0a 22 69
                                       64 6c 65 22 2c 36 34 2c 31 31 33
                                       2c 6d 6f 72 70 68 0d 0a 22 69
       ; "AAF\r\n18\r\n\"idle\",64,113,morph\r\n\"i..."
data\animations\aaf\cannon.aaf:0x0000  41 41 46 0d 0a 34 0d 0a 22 69 64
                                       6c 65 22 2c 31 2c 31 2c 6d 6f 72
                                       70 68 0d 0a
       ; "AAF\r\n4\r\n\"idle\",1,1,morph\r\n" — static artillery idle
```

**Census (observed):** 246/246 files satisfy magic + count + row parse; 62
distinct action names; most common `idle` (236), `walk` (124), `death` (114),
`attack0` (93); frame starts range 1..740. No file uses a flag other than
`morph`; no loop/clamp flag exists anywhere (UNVERIFIED port policy).

### 4.4 ACL payloads (animation-clip logic — OSW config dialect)

**Magic: observed** `section.begin` at byte 0 (`73 65 63 74 69 6f 6e 2e 62
65 67 69 6e`); no version token. CRLF ASCII, indent-based nesting. This is the
same "OSW config" dialect as `.lib`, `.mat`, `.pfx`, `.aix`, `.snd` (P7 §2.3).

Grammar (observed, `cannon.acl`):

```
section.begin
  [*] : struct.begin {refurl=.\data\animations\ref\refunit.acl; refkey=.idle}
     From = idle                       ; source AAF action name
     Name = idle                       ; exported clip name
     global : struct.begin {refurl=...\refspeed.acl; refkey=.cannonidle}
     struct.end
     items[0].AnimationName = idle     ; simple form
  struct.end
  [*] : struct.begin                   ; complex form (attack0/1)
     CyclesList = False
     Options : struct.begin {acoSmoothAnimation=True, acoRandomFrame=False,
                             acoRandomCycle=False, acoSkipActions=False}
     global : struct.begin {refurl=...\refspeed.acl; refkey=.cannonidle}
        Action = actTrackPoint
        TrackPointIdleName = 
        TrackPointMode = mmNone
        TrackPointPreset = 
     struct.end
     items : struct.begin
        [0] : struct.begin {Action=actExecuteState, ExecuteStateName=OnAclAnimationReachedAttack}
        [1] : struct.begin {Action=actAnimation, AnimationName=attack0, NumberCycle=1}
        [2] : struct.begin {Action=actExecuteState, ExecuteStateName=OnAclAnimationReachedAttackEnd}
     struct.end
  struct.end
...
section.end
```

| Property | Observed on `cannon.acl` |
|---|---|
| size / lines | 2,820 B / 85 CRLF |
| `struct.begin` / `struct.end` | 19 / 19 (balanced) |
| `section.begin` / `section.end` | 1 / 1 |
| distinct `refurl` | `.\data\animations\ref\refunit.acl`, `.\data\animations\ref\refspeed.acl` |
| distinct `refkey` | `.idle`, `.walk`, `.default`, `.cannonidle`, `.cannonwalk` |
| clip `Name`/`From` pairs | idle, walk, attack0, attack1, death |

**Short hexdump (`path:offset`):**

```
data\animations\acl\cannon.acl:0x0000  73 65 63 74 69 6f 6e 2e 62 65 67
                                       69 6e 0d 0a 20 20 20 5b 2a 5d 20
                                       3a 20 73 74 72 75 63 74 2e 62 65
                                       67 69 6e 20 7b 72 65 66 75 72 6c
                                       3d 2e 5c 64 61 74 61 5c 61 6e 69
       ; "section.begin\r\n   [*] : struct.begin {refurl=.\data\ani..."
data\animations\acl\cannon.acl:0x005c  46 72 6f 6d 20 3d 20 69 64 6c 65
       ; "From = idle"
```

**Inheritance chain (observed):** `refunit.acl` supplies struct templates
(`default`, `idle`, `walk`, …) including `TrackPointMoveStep`,
`TrackPointTurnStep`, `aco*` defaults; `refspeed.acl` supplies per-class speed
presets (`infantryidle/walk`, `peasantidle/walk`, `hardhorseidle/walk`,
`fasthorseidle/walk`, `cannonidle/walk`, `mortaridle/walk`, …). Example:
`cannonwalk` → `TrackPointMoveStep = 0.020625`, `TrackPointTurnStep = 2.225`.
This is a **data-level** explanation of ACL playback; the mapping from
`items[n].Action` codes to engine behaviour is still **UNVERIFIED** (P7 T-4).

**Census (observed):** 30/30 ACL files contain both `section.begin` and
`section.end`; `struct.begin` count ranges 4..414 (heavy use of inherited
templates); 29 distinct `Name`/`From` values; `items[n].AnimationName` values
are `idle`, `walk`, `death`, `walk0`, `workfood`, `workwood`, `workstone`,
`construct`.

---

## 5. Cross-reference model (skin ↔ mesh ↔ action ↔ clip ↔ audio)

```
data\actors\<kind>\<sid>.actor                              (OSW config, observed)
  section.begin {refurl=.\data\actors\ref\refunit.actor}
    Animations.LoadFromFile = .\data\animations\aaf\<sid>.aaf
    ActorList.Items[0].Name = <sid>.mesh
    ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile = ...\<sid>.oss
  section.end

  <sid>.oss   ── v/fc/t/weights/b·k tracks, fps=30 (header int #1)
  <sid>.aaf   ── "name",first,last,morph  (inclusive donor frames)
  <sid>.acl   ── Name/From/items[n].AnimationName + refkey → refunit/refspeed.acl
  <sid>.osm   ── static variant / construction stage / LOD (no animation)
```

Evidence (observed): `data\actors\units\peaukr.actor` lines 2-6 bind exactly
`peaukr.aaf` + `peaukr.oss`; `data\actors\pfx\shot\shotmusket1.actor` binds
`pfx\pfxshotmusket1.aaf` + `shotmusket1.oss` and inherits
`data\actors\ref\refpfxbones.actor` — matching P3 §4.3. Attached hand tools are
separate single-bone `.oss` on the same AAF timeline (e.g.
`peaukr_{axe,bag,cart,hammer,hoe,lumber,pick}.oss`, b=1; P2 §4).

**ACL library binding (observed, whole-donor text sweep):** 266 `.acl`
references occur in donor config text — 153 in `.lib`, 112 in `.acl` (refurl
includes), 1 in `.inc`. `data\animations\acl\acl.lib` (12,720 B) is a
`section.begin` list of `Name = <sid>` / `FileName = .\data\animations\acl\<x>.acl`
pairs (e.g. `pikeman → infantry.acl`, `cannon → cannon.acl`), i.e. the ACL
equivalent of `sounds.slc`. This is the concrete sid→ACL linkage that P7 T-4
was looking for at the *data* level; engine-level playback semantics remain
UNVERIFIED.

Audio chain (observed): `data\sounds\sounds.slc` → three `.snd` libraries →
`Path = .\data\sounds\<lib>\<clip>.ogg`. Event→clip index is in
`data\scripts\weapon.script` / `sound.script` (P3 §5). There is **no** binary
link between `.oss`/`.aaf` and audio; they meet only at the game-object/script
layer.

---

## 6. Specific questions — verify / refute / refine

### 6.1 Bone hierarchy / parent indices — **absence CONFIRMED; "identity bind" REFUTED**

**Confirmed (observed, two ways):** there is no parent table, no parent index
field and no bone-name string in any `.oss`:
1. 335/335 exact size closure with **zero slack** — every byte is accounted for
   by header + vertices + faces + UVs + UV-faces + weight lists + `b·k·28`.
2. Zero occurrences of `bone`, `parent`, `skel`, `hierarch`, `joint` in all 335
   files; zero strict ASCII runs ≥8 chars with ≥3 letters; weight-list leading
   int32 is a *list length*, never a parent pointer.
3. The 7-float record is fully consumed by position + **unit** quaternion
   (norm `0.9999999169..1.0000001079` across sampled frames of all 335 files).
   Integer-valued floats occur (0.0 and 1.0 at bind frames) but are quaternion
   components, not stable indices — **refutes** "a parent index is hidden in a
   float slot".

The only `ParentIndex` text anywhere in the donor text families is in
`data\objects\ref\refunit.prop:375` (`ParentIndex = 0`), an **object/hotkey**
property, not a bone (P2 E29; this pass). EXE RTTI has `TSkeletonBone`,
`TSkeletonBoneList`, `TSkeletonFrame`, `TSkinnedMeshObject` but 0 code refs
(P2 E27/E28/E32–E36) — INFERRED to exist internally, statically unreachable.

**Refined / corrected (derived):** P2 F4 ("frame 0 is an exact bind pose for
*every* bone") is **false for multi-bone unit files**. Measured max over all
bones at frame 0:

| File | bones | max\|p\| @f0 | max\|q−I\| @f0 | best identity frame |
|---|---:|---:|---:|---:|
| `peaukr.oss` | 20 | 0.09912 m | 0.01189 | rotation f=4 (err 3.0e−8) |
| `pikeman.oss` | 20 | 0.11305 m | 0.07122 | — |
| `yacht.oss` | 20 | 0.05872 m | 0.03224 | rotation f=13 (err 8.7e−3) |
| `ausbaranim.oss` | 10 | 0 | 0 | f=0 (exact) |
| `eurgolanim.oss` | 7 | 6.6e−24 | 8.9e−16 | f=0 (exact) |
| `cossackdon.oss` | 16 | 2.3722 m | 0.17200 | rotation f=210 (err 5.7e−14) |
| `galley_paddle_r.oss` | 13 | 4.9024 m | — | f=278 (exact) |

Whole-family: **175/335** files have frame-0 identity error <1e−5 — this is
**all 124 `b=1` files** plus mostly small attach meshes, and **0 of the 22
`b=20` files**. P2 evidently checked bone 0 only (bone 0 at frame 0 is indeed
≈identity in the sampled units). Consequence: **the stored transforms are not
deltas from a zero bind pose** for unit skeletons; a rotation-bind frame with
non-zero translations exists.

**Skin equation (observed / inferred / UNVERIFIED).** The shipped
`bake_sprites.py:131-143` applies form (1) `v' = Σ w (R(q)·v + p)`. Measured
displacement from the stored bind vertices at frame 0: `peaukr` **0.09496 m**
(max) / 0.05385 m mean, `pikeman` 0.14911 m, `yacht` 0.06822 m,
`cossackdon` 2.55275 m. P2's claimed 1.6e−7 m for peaukr is **not reproducible**.
Form (2) `v' = Σ w (R(q)·(v − p) + p)` (rotation about the stored pivot)
reproduces the stored verts to **3.9e−8 m** at `peaukr` frame 4 and **5.7e−13 m**
at `cossackdon` frame 210 — but this is partly tautological (at any frame with
`R=I`, form (2) reduces to `v`). **INFERRED:** a frame with identity rotations
plus per-bone translations is the bind frame and the correct model needs a
non-identity inverse bind matrix (standard `Σ w (R·(v−t_bind)+p)`). **UNVERIFIED:**
which exact form the donor engine uses — bytes alone cannot decide it, and no
rendered A/B exists. Emitting absolute matrices from the read data remains the
safe bypass.

### 6.2 Morph targets — the "733/733 verts" claim **resolved**

**Observed:** peasant `.oss` has `v=577` vertices and `t=733` UVs; the converted
`app/assets/models/obj/peasant.obj` has `577 v`, `733 vt`, `921 f`
(first `v 0.062326 -0.057036 0.384664`, first `f 12/1 27/2 2/3`).
**Derived:** the "733/733 verts changed" figure in
`AUDIT3D_TRIAGE.md:36`, `V778_ship_skins.md:190-204`, `V774_consume_poses.md:131`
refers to **733 de-indexed rendered corners** (the OBJ `vt` count), because
Godot's OBJ importer de-indexed peasant to 719 vertices and the consumer
re-parses OBJ topology (P10, `V774:80`). It is **not** a donor vertex count and
**not** evidence of 733 morph targets. Morph data delivered by `anim3d.gd` is
577 donor vertices; the mesh consumer expands to 733 corners. No separate
morph-target table exists in `.oss` — poses are sampled from `b·k` tracks.

### 6.3 Action frame ranges and FPS — **confirmed**

FPS = 30 is a header field (`int` at `.oss:0x4`) in 335/335 files (observed).
AAF `first,last` are inclusive (observed), so clip length in seconds =
`(last−first+1)/30`. Independently confirmed on 51/51 attack actions by P5
(`ANIM_ATTACK.md:26-44`) and on the cadence bands by P4
(`ANIM_ADJUDICATION.md:25-28`). Sample ranges: `peaukr.aaf walk 1..20` (0.667 s
donor), `idle 64..113` (1.667 s), `attack0 237..254` (0.6 s); `cannon.aaf idle
1..1` (static, 1 frame), `walk 1..99` (3.3 s). P5 also proves attacks are
one-shot (`loop=false`), while `.aaf` itself carries no loop flag
(**UNVERIFIED** policy for `death`).

---

## 7. What blocks a faithful skin/rig port

| Item | Status | Why |
|---|---|---|
| Bone parent table | **Confirmed absent** in `.oss` (§6.1) | No slack, no strings, 7 floats fully consumed. But a joint tree may be **unnecessary** if transforms are absolute (P2 F5, INFERRED). |
| Bind pose / inverse bind matrices | **Refined blocker** (§6.1) | Frame 0 is not identity for multi-bone files; P2's identity-IBM recipe is not donor-exact by measurement. Need to settle bind frame + skin form via rendered A/B. |
| Donor-authored bone names / semantic labels | **UNVERIFIED / absent** | No ASCII skeleton table in any readable file; only for authoring/UI, not deformation. |
| Quaternion convention for glTF/Godot | **UNVERIFIED** | `bake_sprites.qmat` uses a transposed (row-vector) matrix; no donor citation for column-vector glTF. Bypassable by emitting matrices directly. |
| Exact skin equation form | **UNVERIFIED** | §6.1 forms (1)/(2)/(3) indistinguishable from bytes without donor code or visual A/B. |
| Visual parity | **UNVERIFIED** | No donor-render screenshot comparison has ever been made (P2 §7.4, P9 §5). |
| Attached hand tools | **Known, separate assets** | 7 peasant tool `.oss` (b=1) need separate skinning on the same AAF timeline. |
| Clip loop/clamp, yaw policy | **UNVERIFIED** | No loop flag in AAF; yaw has no donor citation (P1 §3.3.3). |
| `.osm` extra vertex frames | **UNVERIFIED semantics** | 130 files carry 1+ extra un-headered vertex frames (e.g. `spruce1`); may be wind/LOD pose — not decoded. |
| GLES3 skinning at 200/552 units | **UNVERIFIED** | No windowed benchmark (P1 C11). |

Do **not** present an invented bone tree as donor parity. The defensible path
remains: read the absolute per-frame matrices from the bytes, use a flat-root
`Skeleton3D`/glTF node list with matrix animation, and keep the
`PORT APPROXIMATION — NOT DONOR PARITY` label until an A/B settles the bind form
and the visual result.

---

## 8. Audio findings

### 8.1 Audio container formats (binary, observed)

**`.ogg` — standard Ogg Vorbis.** No donor-specific wrapping. Page anatomy from
`data\sounds\units\musket1.ogg:0x0`:

| Byte offset in page | Size | Field | Sample value |
|---:|---:|---|---|
| 0 | 4 | capture pattern `OggS` | `4f 67 67 53` |
| 4 | 1 | stream version | 0 |
| 5 | 1 | header type | 2 (beginning of stream) on page 0 |
| 6 | 8 | granule position | 0 on headers, 2560 on page 2 |
| 14 | 4 | serial number | `0x0000127f` |
| 18 | 4 | page sequence | 0,1,2,… |
| 22 | 4 | CRC32 | e.g. `0xaa474ea1` |
| 26 | 1 | page segments `nseg` | 1 (header page), 17/21 (later) |
| 27 | `nseg` | segment table | 30-byte ID packet on page 0 |

First packet (offset 28) is the **Vorbis identification header**:
`01 76 6f 72 62 69 73` (type 1 + `vorbis`), version `u32=0`, channels `u8=2`,
rate `u32=44100`, bitrate max/nominal/min `i32/i32/i32` = `0 / 499821 / 0`,
blocksize byte `0xb8` (low nibble 8 → 256, high nibble 11 → 2048), framing flag
`0x01`. Page 1 payload begins `03 76 6f 72 62 69 73` — comment header with
`u32 vendor_len=34`, vendor bytes `Xiph.Org libVorbis I 20150105 (??]` (the
`??` are literal `0x3f 0x3f` in the file) and `u32 comment_count=0`. Setup header
`05 76 6f 72 62 69 73` begins at absolute offset 152 in this file.

```
data\sounds\units\musket1.ogg:0x0000  4f 67 67 53 00 02 00 00 00 00 00 00
                                      00 00 7f 12 00 00 00 00 00 00 a1 4e
                                      47 aa 01 1e 01 76 6f 72 62 69 73
       ; OggS page0, serial 0x127f, nseg=1, 30-byte packet
data\sounds\units\musket1.ogg:0x001c  01 76 6f 72 62 69 73 00 00 00 00 02
                                      44 ac 00 00 00 00 00 00 00 00 00 00
                                      6d a0 07 00 00 00 00 00 b8 01
       ; \x01vorbis, v0, 2ch, 44100 Hz, nominal 499821, blocksize 0xb8, framing 1
```

**Census (observed, 325/325):** all Ogg Vorbis version 0, **stereo**; rates
`48000` (251 files) and `44100` (74); nominal bitrate `499821` (246) or
`320000` (79); blocksize byte `0xb8`, framing 1; identical 34-byte vendor
string; page counts mostly 5–18. No `.wav`/`.mp3` files are shipped — the
`TOSWWAVFile`/`TOSWMP3File`/`TOSWOGGFile` RTTI in P3 §2 describes decoder
*types*, not on-disk assets.

### 8.2 `.snd` manifests and `.slc` library index (ASCII, observed)

`data\sounds\sounds.slc:0x0` contains three `section.begin … section.end`
blocks:

```
section.begin\r\n NameLibrary=units\r\n FileNameLibrary=.\data\sounds\units\units.snd\r\nsection.end\r\n
section.begin\r\n NameLibrary=interface\r\n …\interface.snd\r\nsection.end\r\n
section.begin\r\n NameLibrary=ambient\r\n …\ambient.snd\r\nsection.end\r\n
```

Each `.snd` is a record list. `units.snd:0x0` begins:

```
sound : section.begin\r\n   Name = \r\n   Path = \r\n   DefPriority = 100
   DefVolume = 1   DefMinDistance = 1   DefMaxDistance = 100
   DefInsideConeAngle = 360   DefOutsideConeAngle = 360
   DefConeOutsideVolume = 1   DefNbLoops = 1   DefFrequency = -1
   DefRandomOffset = 0   DefKillSndOutOfRad = False   VolumeGroup=svgSFX
section.end\r\n
section.begin {refkey=sound}\r\n   Name = musket1
   Path = .\data\sounds\units\musket1.ogg   DefPriority = 1000
section.end\r\n ...
```

The first record is an **empty template** (`Name = `, `Path = `) that supplies
defaults; subsequent `section.begin {refkey=sound}` records override fields.
Census: `units.snd` 248 `Path` lines (247 non-empty), `interface.snd` 52 (51
non-empty), `ambient.snd` 27 (27 non-empty) → **325 declared clips**, exactly
matching the **325 on-disk `.ogg`** (distinct paths, 1:1 after stripping the
`.\` prefix). This **resolves** P6 DE_AUDIO_UI's "327 declared vs 325 files —
2 duplicates/missing UNVERIFIED": the two extra lines are the empty template
`Path = ` records in `units.snd` and `interface.snd`, not missing assets.

Semantics (from P3, not re-derived here): event→sound-index map in
`weapon.script:400-425`, clip families in `sound.script:87-230`, per-cell
aggregation in `gui.script:3090-3209`, outer radii `loudness·1.25` =
25/50/75/100 world units, `SetSndSoundRadius(8000)` for isometric skirmish.
`AudioStreamPlayer3D` in the port is a structural analogue, not a donor copy
(donor software-mixes via winmm `waveOut*`; P3 §2/§10).

---

## 9. Open questions

1. **Skin form / bind frame (BLOCKING for parity).** Is donor deformation
   `Σw(R·v+p)`, `Σw(R·(v−p)+p)`, or `Σw(R·(v−t_bind)+p)`? §6.1 favours a
   non-identity IBM at a rotation-bind frame; needs donor code or a rendered A/B.
2. **Rotation-bind frame selection.** Is it derivable from the data (e.g. frame
   minimizing `|q−I|` across bones: peaukr f4, cossackdon f210), or stored
   elsewhere? 101 `.osm` files and 160 multi-bone `.oss` files need a policy.
3. **`.osm` extra vertex frames.** What are the 16-byte `FRAME`-less blocks after
   `oe` in 130 files (wind/LOD/second pose)? `nf` only correlates in 29 of them.
4. **ACL action semantics.** Mapping of `items[n].Action` (`actAnimation`,
   `actTrackPoint`, `actExecuteState`) to playback is still at data level only
   (P7 T-4).
5. **AAF loop/clamp and yaw.** No flag in `.aaf`; no donor citation for yaw.
6. **Bone names.** Any readable semantic labels (head/left arm) in a `.lib`
   refkey chain or `.actor` template? Text sweep found none so far.
7. **Ogg bitrate field.** `499821` is likely an encoder placeholder, not kbps;
   unit conversion to Godot audio is UNVERIFIED (P3 §8).
8. **Visual parity / perf.** No donor A/B and no GLES3 skinning benchmark.

---

## 10. Evidence index

### Craft Anything evidence ids (stable across sessions; this lane's byte searches)

| id | Path:offset / finding |
|---|---|
| `ev_cd615ee54602c2177d2410e1641a760b0d294afd3b838c01f2d4141f88131b0d` | `peaukr.oss` triage, 312,376 B, sha256 `1c356bcf…` (P2 E1) |
| `ev_51368719fc852c2f04ff464f3e925da2a89b16831411706f09c9810299a9e50a` | `pikeman.oss` triage, 225,352 B, sha256 `c408b5a6…` (this pass) |
| `ev_8f2d4059410f3c007c72770fd263d04d9bc55a74472507aafd594313a0bd50b6` | `peaukr.oss:0x0` pattern `e3 01 00 00 1e 00 00 00 14 00 00 00` (1 match) |
| `ev_d77efe75c74efe5a860901c9b5be3d302b894a8cc4db06b2c4dbc66d117d208f` | `spruce1.osm` triage, 60,300 B (P2 E4) |
| `ev_b99b4a21f15ea995d9c5a1ec48ffa49bf3b4e264ae878f96cfd1fce3acb82a5d` | `algcen.osm` triage, 224,412 B (P2 E5) |
| `ev_690d07dd20d5152559ffd7d2461b7f572c74e48c4b8425e45bc8f5a364349b95` | `spruce1.osm:0x0` text `IDP2` (1 match) |
| `ev_7f93b6c832c07d727a2a045a356a786012b7ea0bd52c9f14f8d6fbb8dc626581` | `peaukr.aaf:0x0` text `AAF` (1 match) |
| `ev_00732d2430d13c70cc346efe5ebcb6f6308500dab6de39c4e4809823675de2c6` | `cannon.acl:0x0` text `section.begin` (1 match) |
| `ev_9826ad9510e9d2a2077d059c2e90606fa228327227aa341c073388ab7b173085` | `musket1.ogg` triage, 266,576 B, sha256 `0ecf763a…` (this pass) |
| `ev_b9f6d9017f4c912dc795f99227403102cc2d5e75f9a691f6fb4a518e8fe06fa0` | `musket1.ogg` text `OggS` — matches at 0x0, 0x3a, 0xfdc |
| `ev_392885a608730538a874722dbd0c6e6b3e0ad14e030c533695e835f47aa829b8` | `.oss` family evidence (P7) |
| `ev_0bbb20c11bb3e0ce0d9c17d0fa68816cf348ae46d0d3a2dbc029019e27d0d136` | `.osm` family evidence (P7) |
| `ev_6a6b0380c96f96da8d583413f39352e7b4b1f054532df69124760c6ddbf5a71f` | `.aaf` family evidence (P7) |
| `ev_e5ad6408513ec3e68c34d45050fb1767652d6ec5719e683f4c4bea9235d4e401` | `.acl` family evidence (P7) |

### Craft Anything investigation findings recorded this lane

`fnd_1` `.oss` layout/closure/no parents; `fnd_2` frame-0 identity refutation;
`fnd_3` `.osm` magic/version/extra frames; `fnd_4` `.aaf`/ACL census;
`fnd_5` audio containers and path reconciliation; `fnd_6` 733-corner
resolution. (All with confidence `observed` or `derived`; revision 6.)

### Direct `path:offset` measurements (Python, this pass)

`.oss` headers/weights/tracks: `peaukr.oss:0x0,0x8864,0xa3a8`;
`pikeman.oss:0x0,0xa35c,0xc5c8`; `yacht.oss:0x0,0x8d08,0xa8a0`;
`ausbaranim.oss:0x0,0xdbc,0x1188`; `shotmusket1.oss:0x0,0x1f8,0x258`.
`.osm`: `spruce1.osm:0x0,0x2c,0x44,0x7f9c`; `algcen.osm:0x0,0x23a3c`;
`yacht.osm:0x0,0x43c5c`.
`.aaf`: `peaukr.aaf:0x0`; `cannon.aaf:0x0`; `yacht.aaf:0x0`.
ACL: `cannon.acl:0x0,0x5c`; `yacht.acl:0x0`; `ref/refunit.acl:0x0`;
`ref/refspeed.acl:0x0`.
Audio: `sounds.slc:0x0,0x60,0xd0`; `units.snd:0x0`; `musket1.ogg:0x0,0x1c,0x3a`.
Repo cross-check: `app/assets/models/obj/peasant.obj` `577 v / 733 vt / 921 f`.

---

## 11. Summary

| Format | Magic/version | Layout status | Key numbers |
|---|---|---|---|
| `.oss` | **none** (first int = `k`); header `<6i` at `0x0` | **Fully decoded**, tight LE, 335/335 exact closure | fps=30 all; b=1..42; k=24..755; 7-float bone records; no parent table |
| `.osm` | `IDP2` (`0x32504449`), version 8, 17 int32 at `0x0` | **First frame fully decoded**; 130/3,897 have extra vertex frames | `ou/ot/of` at header ints 12/13/14; fixed 64-B + 16-B ASCII headers |
| `.aaf` | `AAF` at `0x0`, line 2 = count, CRLF | **Fully decoded**; 246/246 parse | 1,434 rows, all flag `morph`, inclusive frames 1..740 |
| `.acl` | `section.begin` at `0x0`, OSW dialect | **Text decoded**; semantics partial | 19/19 balanced structs in `cannon.acl`; refkey → `refunit/refspeed.acl` |
| audio | `.snd`/`.slc` = `section.begin` text; `.ogg` = `OggS` v0 | **Containers fully decoded** | 325 Ogg Vorbis (2 ch, 48/44.1 kHz); 247+51+27 = 325 declared clips |

**Biggest corrections delivered:** (1) DEEPDEC-06's "frame 0 is bind for every
bone / 1.6e−7 m skin error" is refuted for multi-bone files — frame 0 has up to
2.4 m translation error and 0.05–2.5 m skin displacement; the correct bind form
needs a visual A/B. (2) The bone-parent *absence* is reconfirmed by three
independent methods, but a joint tree may be unnecessary because transforms are
absolute. (3) "733/733 verts" is a rendered-corner count (OBJ `vt`), not donor
skin vertices. (4) The audio "2 missing clips" was an artifact of two empty
template `Path = ` lines — the 325 declared clips map 1:1 to 325 oggs.

No donor file was copied or executed; no code, asset or git change was made.
All measurements are reproducible from the cited donor `path:offset` values and
the evidence ids above.

---
*DEC-04, 2026-11-25. Read-only donor recon. No donor executable run, no donor
bytes copied into the repo, no code edits. All donor facts cite a path+offset or
an evidence id; uncertainties are labelled UNVERIFIED.*
