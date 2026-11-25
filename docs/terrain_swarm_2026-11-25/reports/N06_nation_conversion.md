---
id: WAVE-N-N06
ticket: N06 (Wave N — NATION OBJECT ASSOCIATIONS)
title: "N06 — minimal additive donor->OBJ conversion plan for ruscen + 8 nation peasants (READ-ONLY design)"
owner: N06 subagent
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_CODE_EDIT__NO_DONOR_COPY__NO_GODOT
labels: [OBSERVED, DERIVED, UNVERIFIED]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). 'Donor-derived' = file/mesh provenance, never a rendered-look claim. No Godot was launched, no runner job was submitted, no donor binary was copied into the repo or executed."
scope: "One file written: this report. No .gd/.json/.py/asset/config/test edit. Read-only donor byte/text probes only; throwaway probe scripts live outside the repo in %TEMP%\\opencode."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md (Wave N:157-169)
---

# N06 — exact minimal additive conversion plan (design only)

## 0. Direct answer

**DERIVED (high confidence, byte-level).** The fix is **not** a runtime trick: the port's
converter only ever mapped `peasant -> peaukr` and `cen -> ukrcen`, so no nation-stemmed
mesh can be found on disk (N01 §1-2, N03 §3-4). The minimal additive art set is:

- **1 building**: `ruscen` from donor `data/actors/buildings/rus/ruscen.osm` +
  `data/materials/buildings/rus/ruscen.dds` → `obj/ruscen.obj`, `tex/ruscen.png`.
- **8 units**: `pearus`, `peaukr`, `peapol`, `peaaus`, `peaeng`, `peaspa`, `peatur`,
  `peasco` from `data/actors/units/pea<X>.oss` + matching `data/materials/units/pea<X>.dds`
  (+ each nation's own `data/animations/aaf/pea<X>.aaf` for skins) →
  `obj/pea<X>.obj`, `tex/pea<X>.png`, `skin/pea<X>.json`.

Nine new manifest entries, **inserted textually before** the current first entry so all
280 existing entries stay byte-identical. No existing file is rewritten in place except
the two insertion targets (`manifest.json`, `skin/index.json`) and the CREDITS note.
**Everything visual remains UNVERIFIED** — no capture, no Godot, no donor A/B frame.

Note on line numbers: every `file:line` below is from this pass (2026-11-25) while other
Wave N/P agents were editing concurrently; re-confirm the exact lines at implementation.

---

## 1. (a) Donor selection — exact files, read-only evidence

All donor paths below were checked **read-only** this pass against the installed game at
`C:\Games\Cossacks 3` (existence + byte size + header bytes + text reads). No donor file
was copied, opened for write, or executed. N02 independently confirms the same sids from
`country.script` / `.actor` / `.prop` primaries (N02 findings A1/A2/B1/C1/C2/C3).

### 1.1 Russian Town Hall — `ruscen`

| Role | Donor path (read-only) | Bytes | Evidence |
|---|---|---|---|
| mesh | `data\actors\buildings\rus\ruscen.osm` | 609,492 | OBSERVED: `ruscen.actor` lines 3-4 `Name = ruscen.mesh` / `MeshObjects.LoadFromFile = .\data\actors\buildings\rus\ruscen.osm`; IDP2 v8, 15,348 verts / 9,936 tris / 1 frame (header bytes read this pass) |
| albedo | `data\materials\buildings\rus\ruscen.dds` | 5,592,560 | OBSERVED: exists; `data\objects\buildings\ruscen.prop` `Mesh[0].DefaultMaterialName = ruscen` (summer), `ruscenw` (winter, not used) |
| actor (citation only) | `data\actors\buildings\rus\ruscen.actor` | 1,709 | OBSERVED text: build stages `ruscen1..4.osm`, ruins `ruscen_death1/2.osm` |

Why this is genuinely a different hall (not a rename): `ruscen.osm` is **15,348 verts /
9,936 tris**, vs `ukrcen.osm` **5,611 verts / 3,714 tris** (both IDP2 v8, 1 frame).
Read-only first-frame bboxes:

- `ruscen`: `[-6.54600715637207, 5.613785743713379, -6.916341304779053, 6.135779857635498, -0.003664474468678236, 8.12759017944336]`
- `ukrcen`: `[-7.052096843719482, 7.052096843719482, -6.525235652923584, 6.525235176086426, -0.22895121574401855, 11.905742645263672]`

So the Russian hall is ~2.7x denser, ~12.16 m wide (vs 14.10 m) and ~8.13 m tall
(vs 11.91 m). **UNVERIFIED:** how that reads on screen, and whether collision/ghost
footprint needs separate reconciliation (a smaller/taller-different mesh can expose the
known footprint/ghost approximations). This is a PORT APPROX, not a donor-parity claim.

### 1.2 Eight nation peasants

| Port sid | Donor `.oss` (bytes) | Donor `.dds` | Donor `.aaf` | `.oss` header `k/fps/bones/verts/faces/uv` |
|---|---|---|---|---|
| `pearus` | `pearus.oss` (338,128) | `pearus.dds` (349,680) | `pearus.aaf` (455) | 486/30/22/527/864/662 |
| `peaukr` | `peaukr.oss` (312,376) | `peaukr.dds` (349,680) | `peaukr.aaf` (455) | 483/30/20/577/921/733 |
| `peapol` | `peapol.oss` (368,008) | `peapol.dds` (349,680) | `peapol.aaf` (455) | 483/30/24/629/935/734 |
| `peaaus` | `peaaus.oss` (293,664) | `peaaus.dds` (349,680) | `peaaus.aaf` (455) | 483/30/18/714/1058/957 |
| `peaeng` | `peaeng.oss` (366,312) | `peaeng.dds` (349,680) | `peaeng.aaf` (455) | 483/30/24/566/923/728 |
| `peaspa` | `peaspa.oss` (285,608) | `peaspa.dds` (349,680) | `peaspa.aaf` (457) | 483/30/18/557/960/716 |
| `peatur` | `peatur.oss` (317,456) | `peatur.dds` (349,680) | `peatur.aaf` (455) | 483/30/20/565/1039/1055 |
| `peasco` | `peasco.oss` (285,760) | `peasco.dds` (349,680) | `peasco.aaf` (455) | 483/30/18/570/952/717 |

All under `data\actors\units\`, `data\materials\units\`, `data\animations\aaf\`
respectively. **OBSERVED** (this pass + N02 B1): all 24 files exist; the eight `.oss`
are distinct binaries with distinct bone/vertex/face counts; the eight `.dds` are
byte-distinct despite equal size (SHA-256 first 16 hex this pass):
`pearus 50063441D40C4728`, `peaukr 9980ED1D9F23EE6B`, `peapol 0B9EF2258D35D4A4`,
`peaaus 820ED87B7254C023`, `peaeng 8D85043A938ECAFE`, `peaspa D6DC1B570E832257`,
`peatur E876E17A86CAC10A`, `peasco D3FFBCACCB225A69`.
This is real per-nation geometry + albedo data, not a recolour of one mesh
(N02 B3: exact visual silhouette still **UNVERIFIED** without a donor render).

`peaukr` is byte-identical in purpose to the already-shipped generic `peasant`
(`peasant.obj` came from `peaukr.oss`, manifest.json:5-11): its new OBJ will be a
**derived duplicate**. Either keep the uniform 8-stem mapping (`peaukr.obj`) or, to
avoid a duplicate file, map `ukr` to the existing `peasant` stem — the latter makes the
"exact nation mesh" flag less uniform; owner/asset-owner choice, not a blocker.

### 1.3 Frame ranges are per-nation — do NOT inherit `peaukr` values

**OBSERVED** (verbatim AAF text read this pass). Core actions are shared, but some
differ, e.g.:

| action | `peaukr` | `pearus` | `peapol` | others |
|---|---|---|---|---|
| `idle` / `idle0` | 64..113 | 64..113 | 64..113 | same |
| `walk` / `walk0` | 1..20 | 1..20 | 1..20 | same |
| `death` | 115..149 | 115..149 | 115..149 | same |
| `attack0` | 237..254 | 237..254 | 237..254 | same |
| `construct` | 186..198 | 186..198 | 186..198 | same |
| `workwood` | 237..254 | 237..254 | 237..254 | same |
| `workstone` | 217..234 | 217..234 | 217..234 | same |
| `workfood` | 278..299 | **281..304** | **278..301** | peaaus/eng/spa/tur/sco 278..299 |

All eight AAFs have 18 named actions. `pearus.oss` has `k=486` (others 483), so any
hard-coded 483 frame ceiling would silently drop valid late frames. **UNVERIFIED:**
whether the port's action-selection and 30 fps clock behave identically for every
nation; the converter must derive ranges from each nation's own AAF, not copy
`peaukr` numbers (see §5 blocker B5).

### 1.4 Optional stage/ruin art for `ruscen` (not in the minimal set)

Donor stage files **do exist** (read-only sizes this pass):
`rus\ruscen1.osm` 133,988; `ruscen2.osm` 272,588; `ruscen3.osm` 501,148;
`ruscen4.osm` 659,668; `attach\ruscena.osm` 660; `attach\ruscen1a.osm` 175,388;
`attach\ruscen2a.osm` 181,852; `attach\ruscen3a.osm` 226,492;
`attach\ruscen4a.osm` 342,796 (all bytes). `_death1/_death2` also exist per
`ruscen.actor`. The **minimal** fix needs only the finished hall `ruscen.obj`;
without stage conversion the build/ghost stages remain Ukrainian-derived (blocker B3).

---

## 2. (b) Exact tool entry-point changes (proposal — NO edits made)

All line numbers refer to the current, read-only tree. The rule is **additive only**:
the default invocation must keep producing the same 280 outputs and the same
`manifest.json` bytes.

### 2.1 `variant3d/tools/convert_models.py`

| Location (current) | Change (exact intent) |
|---|---|
| after `unit_models()` end, **:243** | Add `nation_peasant_models(game) -> list`. Table of 8 `sid -> base` pairs from §1.2; emit the same shape as :236-243: `{"sid": sid, "kind": "unit", "mesh": <actors>\<base>.oss, "texture": <mats>\<base>.dds, "directions": 8}`. No `obj_name`/`tex_name` override needed — default stem == sid. |
| after `building_models()` end, **:297** | Add `nation_building_models(game) -> list`: one row `("rus", "ruscen", "rus", "ruscen")`, emit `{"sid": "ruscen", "kind": "building", "mesh": <actors>\rus\ruscen.osm, "texture": <mats>\rus\ruscen.dds, "directions": 1}` using :282-288 shape. |
| after `stage_models()` end, **:381** (optional) | Add `nation_stage_models(game)` using the 9 donor files of §1.4 and the `obj_name`/`tex_name` mechanics already at :351-380; stage sids `ruscen1..4`, `ruscen1a..4a`, `ruscena`, scaffold texture as at :332. Opt-in only. |
| `main()` argparse, **:499-509** | Add `--nation-art` (`store_true`: additive set only) and `--manifest-name` (`default="manifest.json"`). Keep `--include-stages` unchanged. |
| `main()` model assembly, **:519-524** | When `--nation-art`: `models = nation_peasant_models(game) + nation_building_models(game)` (plus `nation_stage_models(game)` if `--include-stages`); otherwise the existing four base tables exactly as today. Never mix base + additive into one rewrite. |
| `main()` manifest write, **:559-561** | Write to `os.path.join(out, args.manifest_name)` instead of the hard-coded `manifest.json`; log the same name. Readers/writers :48-158 and `force_opaque` at :542-543 are unchanged. |

Outputs (generator defaults `obj_name = sid`, `tex_name = sid` at :537-539):

`obj/ruscen.obj` + `obj/ruscen.mtl` + `tex/ruscen.png`;
`obj/pearus.obj` + `obj/pearus.mtl` + `tex/pearus.png`; and likewise for
`peaukr`, `peapol`, `peaaus`, `peaeng`, `peaspa`, `peatur`, `peasco`.
(9 new OBJ + 9 new MTL + 9 new PNG; +9/+9/+9 more if stage art is opted in.)
The `.mtl` `map_Kd` points at `..\tex\<sid>.png` (:541); alpha is dropped because
`kind in ("unit","building")` (:542-543) — identical treatment to the base set.

Offline command shape for a future asset owner (**not executed by N06**):

```
python variant3d\tools\convert_models.py --game "C:\Games\Cossacks 3" --out variant3d\assets\models --nation-art --manifest-name manifest_nation_addendum.json
```

That command writes only the 9 new files plus a **separate** addendum manifest; it must
not touch `manifest.json`. Byte-identity is then preserved by the text merge in §3.

### 2.2 `variant3d/tools/convert_skins.py` (sibling pipeline for the 8 peasants)

| Location (current) | Change (exact intent) |
|---|---|
| `main()` argparse, **:279-288** | Add `--index-name` (`default="index.json"`) so an additive run writes `index_nation.json`; keep `--frames-per-action` default 6 and `--actions` default (:80-81, :286-287) unchanged. |
| `main()` index write, **:325-326** | Write `out_dir / args.index_name`. All skin JSONs are still named by sid (`dest = out_dir/(sid+".json")`, :258-260). |

`convert_unit()` already derives the AAF path from the **mesh stem** (:208-211) and
the frame ranges from that nation's own AAF (:215-227); no frame number is hard-coded.
Feeding it the addendum manifest (8 `kind:"unit"` entries) therefore produces
`pearus.json … peasco.json` with their own `actions.*.donor` citations and exported
`frames`. Suggested offline shape (staging dir outside the repo):

```
python variant3d\tools\convert_skins.py --game "C:\Games\Cossacks 3" --manifest variant3d\assets\models\manifest_nation_addendum.json --out <TEMP>\nation_skins --index-name index_nation.json
```

The asset owner then copies only the 8 new JSONs into `variant3d/assets/models/skin/`
and text-appends the 8 index entries into `skin/index.json` (same insertion rule as §3;
`count` 55→63 and `total_bytes` must be recomputed — these scalars are outside the
entries array). Existing 55 skin JSONs must remain byte-identical; BUILD_SKIN_02
records the current baseline (`index.json: count=55, total_bytes=3,720,747`, OBSERVED
this pass).

---

## 3. (c) `manifest.json` — additive entries, 280 existing entries byte-identical

**Strategy (critical).** `convert_models.py:559-561` rewrites the whole manifest with
`json.dump`. Do **not** run the default pipeline into `assets/models`. Generate the
addendum separately (§2), then **textually insert** the new objects immediately after
line 3 (`  "models": [`) and before the current line 4 (`    {` of `peasant`). Each
inserted object ends with `},`; the original line 4 is left untouched. Because the
insertion is *before* the original byte slice, **every byte of the 280 existing entries
(lines 4..5539 today) is preserved** — including the last entry, which needs no added
comma. JSON stays valid; only array order changes (the runtime looks entries up by
`sid`, `world3d_entities.gd:405-412`, so index shifts are harmless).

Exact additive objects (values measured read-only this pass with the converter's own
`read_osm`/`read_oss` vertex order; `json.dump(indent=2)` will expand each `bbox`
array one float per line). `REPO` below abbreviates the literal absolute prefix
`C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3\\variant3d\\assets\\models`;
the generator writes the full path in each entry.

```json
    {
      "sid": "ruscen", "kind": "building",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\buildings\\rus\\ruscen.osm",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\buildings\\rus\\ruscen.dds",
      "directions": 1,
      "obj": "<REPO>\\obj\\ruscen.obj",
      "texture_png": "<REPO>\\tex\\ruscen.png",
      "bbox": [-6.54600715637207, 5.613785743713379, -6.916341304779053, 6.135779857635498, -0.003664474468678236, 8.12759017944336],
      "verts": 15348, "faces": 9936
    },
    {
      "sid": "pearus", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\pearus.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\pearus.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\pearus.obj", "texture_png": "<REPO>\\tex\\pearus.png",
      "bbox": [-0.7173412442207336, 0.7208508253097534, -0.2691120505332947, 0.34032589197158813, 0.0038509436417371035, 2.078381061553955],
      "verts": 527, "faces": 864
    },
    {
      "sid": "peaukr", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peaukr.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peaukr.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peaukr.obj", "texture_png": "<REPO>\\tex\\peaukr.png",
      "bbox": [-0.7172664999961853, 0.7172665596008301, -0.22652101516723633, 0.2853986620903015, 0.006876183673739433, 1.9954692125320435],
      "verts": 577, "faces": 921
    },
    {
      "sid": "peapol", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peapol.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peapol.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peapol.obj", "texture_png": "<REPO>\\tex\\peapol.png",
      "bbox": [-0.722821831703186, 0.7228220701217651, -0.2546897232532501, 0.3117263615131378, -0.000875726283993572, 1.9668229818344116],
      "verts": 629, "faces": 935
    },
    {
      "sid": "peaaus", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peaaus.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peaaus.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peaaus.obj", "texture_png": "<REPO>\\tex\\peaaus.png",
      "bbox": [-0.7263388633728027, 0.7251416444778442, -0.18132208287715912, 0.16057062149047852, -0.0024340273812413216, 2.106261730194092],
      "verts": 714, "faces": 1058
    },
    {
      "sid": "peaeng", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peaeng.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peaeng.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peaeng.obj", "texture_png": "<REPO>\\tex\\peaeng.png",
      "bbox": [-0.7315319776535034, 0.7315319180488586, -0.24335017800331116, 0.25331345200538635, -0.0001334629487246275, 2.1251487731933594],
      "verts": 566, "faces": 923
    },
    {
      "sid": "peaspa", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peaspa.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peaspa.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peaspa.obj", "texture_png": "<REPO>\\tex\\peaspa.png",
      "bbox": [-0.7295829057693481, 0.7296149134635925, -0.24226023256778717, 0.21560491621494293, 0.0008080289117060602, 2.0066075325012207],
      "verts": 557, "faces": 960
    },
    {
      "sid": "peatur", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peatur.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peatur.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peatur.obj", "texture_png": "<REPO>\\tex\\peatur.png",
      "bbox": [-0.730165958404541, 0.7273479104042053, -0.22049738466739655, 0.2777995467185974, 1.3310056601767428e-05, 1.9960899353027344],
      "verts": 565, "faces": 1039
    },
    {
      "sid": "peasco", "kind": "unit",
      "mesh": "C:\\Games\\Cossacks 3\\data\\actors\\units\\peasco.oss",
      "texture": "C:\\Games\\Cossacks 3\\data\\materials\\units\\peasco.dds",
      "directions": 8,
      "obj": "<REPO>\\obj\\peasco.obj", "texture_png": "<REPO>\\tex\\peasco.png",
      "bbox": [-0.7295070290565491, 0.7298194766044617, -0.19304601848125458, 0.16745850443840027, -0.004732318688184023, 1.947142243385315],
      "verts": 570, "faces": 952
    },
```

Validation checklist for the implementing asset owner (no Godot needed):

1. Parse: `json.load()` succeeds; `len(models) == 289`.
2. Byte-identity: take the byte slice from the first `    {` of `peasant` through the
   last `    }` before `  ]` in a pre-merge copy; SHA-256 must equal the same slice in
   the merged file. Same for the `game` header line.
3.sid set: the original 280 `(sid, mesh, texture, obj, texture_png, bbox, verts, faces)`
   tuples compare equal; nine new sids present exactly once.
4. Every new `obj`/`texture_png` file exists on disk after the copy; each `.mtl`
   `map_Kd` resolves.
5. Skin index: 63 entries, 8 new `<sid>.json` files parse, original 55 index entries
   byte-identical after text insertion.

---

## 4. (d) Registration points — later code owner's job (NO N06 edits)

The art can land first; until the code owner wires these, the new meshes will sit on
disk unused. The following is a precise map, not an implementation.

### 4.1 `variant3d/scripts/world3d_entities.gd`

- **Buildings — no selector change needed once `ruscen.obj` exists.**
  `_donor_building_prefix()` (:715-740) puts `cen` in `OWN_FAMILIES` so `nation=="rus"`
  yields candidate `ruscen`; `_entity_mesh_sid()` buildings branch (:790-791) probes
  it; `_nation_mesh_on_disk()` (:702-706) will now succeed; `_mesh_info()` (:1132+)
  will read the manifest bbox/OBJ. `add_building()` (:1701-1724) and its meta tags
  pick it up automatically. The honest labels at :209 / :216 must be updated by that
  owner (they currently assert "0 prefixed OBJs / NOT VISUALLY FIXED") — replace with
  an accurate PORT APPROX label once exact art exists, **without** claiming donor parity.
- **Peasants — add a presentation-only nation map.** In `_entity_mesh_sid()` units
  branch (:774-789), today a candidate is appended only when
  `Data.resolve_sid(nation, base_sid) != base_sid`. Peasant is identity, so no
  candidate. Add a donor-derived table (8 entries, `rus->pearus`, `ukr->peaukr`,
  `pol->peapol`, `aus->peaaus`, `eng->peaeng`, `spa->peaspa`, `tur->peatur`,
  `sco->peasco`; N02 Finding B1) and append `pea<X>` as a candidate for `base_sid ==
  "peasant"`. Keep `exact=true` only on a real disk hit; keep the fallback path intact.
- **Carry the resolved sid into animation.** `add_unit()` (:1653-1695) computes
  `ns["sid"]` but does not store it; `sync()` samples animation with the raw sim sid
  (`var sid := str(ed.get("sid", ""))`, :2111) and calls `pose_for(ed, …)` at :2133.
  With nation art the static mesh would be Russian while morph/skin stay `peasant`
  (already flagged as M6 in N03). Owner should store the resolved sid on the slot in
  `add_unit()` and read it in `sync()` for `has_skin` / `pose_for` / `_morph_mesh`
  (:2127-2142), e.g. pass `{"sid": sid}` to `pose_for` so `anim3d._sid_of()` sees the
  nation sid. **Do not mutate the sim entity's `sid`.**
- **Stage/ghost art remains nation-blind** (`_stage_mesh_info()` :1875+ uses the base
  sid; `world3d_fx.gd:658-669` resolves the finished base first). Either accept the
  mixed look with an explicit label or convert `ruscen1..4`/`ruscen*a` (§1.4) and
  extend the stage path in a separate ticket.

### 4.2 `variant3d/scripts/anim3d.gd`

- **No code edit required for skin registration.** `_ensure_shipped_skins()` (:806+)
  lazily parses `res://assets/models/skin/index.json` and `_load_shipped_skin()`
  (:839+) registers each sid itself; the 8 new `<sid>.json` assets are enough.
- `_sid_of()` (:683+) accepts a Dictionary with a `sid` key — this is the clean way
  for `world3d_entities.gd:sync()` to request the nation pose (see §4.1).
- `_action_range_for()` (:987+) uses each shipped skin's own `actions` / `donor`
  citations; `AAF_ACTIONS` (:71-90) remains the **peaukr-only legacy fallback** and
  must not be used as the source for nation sids (blocker B5).
- `BLOCKED_RIG` (:66) stays: donor bone parent hierarchy unreadable, flat-root skin
  only. No parent matrix may be invented.

### 4.3 `variant3d/scripts/data.gd` — the trap, and two owner options

- `NATION_UNITS` (:294-306) is a **train-list** map, not a presentation map, and
  `resolve_sid()` (:1565-1568) returns `r if UNITS.has(r) else sid`. `pearus` etc.
  have **no `UNITS_BASE` row** (:638+), so naïvely adding
  `"rus": {"peasant": "pearus"}` would be silently rejected and change nothing
  (same trap already recorded in `coord_swarm_2026-11-25/reports/B_NATION_PLAN2.md:70,96`).
  **BLOCKER B1.**
- **Recommended (minimal, presentation-only):** keep `data.gd` untouched; put the
  8-entry map in `world3d_entities.gd` §4.1. Sim stats/training stay on `peasant`.
- **Alternative (owner decision, higher blast radius):** add 8 `UNITS_BASE` rows that
  duplicate the `peasant` block (:639-647) under the nation sids so `resolve_sid`
  passes, then add the `NATION_UNITS.peasant` rows. This changes the sim's unit
  vocabulary (AI pickers, train lists, save/load) and must be gated separately.
  Do not do both.

### 4.4 Labels / telemetry to update together

`NATION_MESH_FALLBACK_STATUS` (:209), `NATION_MESH_BLOCKED_EVIDENCE` (:216), and the
stats fields at :490/:492 currently say the art is absent. Update them in the same
commit as the code wiring so telemetry (`nation_mesh_usage`, `nation_mesh_exact`) does
not lie; keep "visual UNVERIFIED" until a real capture exists.

---

## 5. 2D nation-sheet validation (consistency check, OBSERVED)

Enumerated `app/assets/models/anim/<nat>/` and `variant3d/assets/models/anim/<nat>/`
this pass (PNG names, `.import` sidecars ignored):

| Nation | 2D peasant sheets (`<nat>_peasant_*`) | 2D hall sheets (`<nat>_cen*`) | Donor peasant (N02 B1) | Proposed 3D sid | Consistent? |
|---|---|---|---|---|---|
| rus | 14 (idle/walk/death/attack/construct + carry/work variants) | 6 (`rus_cen`, `_s1..s4`, `_dead`) | `pearus` ("Serf") | `pearus` + `ruscen` | YES |
| ukr | 14 | 6 | `peaukr` | `peaukr` (or existing `peasant` alias) | YES |
| pol | 14 | 6 | `peapol` | `peapol` | YES |
| aus | 14 | 6 | `peaaus` | `peaaus` | YES |
| eng | 14 | 6 | `peaeng` | `peaeng` | YES |
| spa | 14 | 6 | `peaspa` | `peaspa` | YES |
| tur | 14 | 6 | `peatur` | `peatur` | YES |
| sco | 14 | 6 | `peasco` | `peasco` | YES |
| bav | **none** | 6 | `peaaus` | no new art (keep `peasant` fallback) | 2D-consistent fallback |
| swe | **none** | 6 | `peaeng` | no new art (keep `peasant` fallback) | 2D-consistent fallback |

Conclusions (DERIVED):

1. The proposed 3D stems match the 2D vocabulary `<nat>_peasant` / `<nat>_cen` modulo
   the 2D underscore separator; the no-separator form is exactly what the 3D selector
   already probes (`ruscen`, `pearus`), so no new naming convention is introduced.
2. The 8 nation peasant bases are precisely the nations with 2D `<nat>_peasant` sheet
   sets (N03 §2, `land_units/index.json` keys) — the requested scope is 2D-proven.
3. Bavaria/Sweden are a deliberate exception: donor has correct bases (`peaaus` /
   `peaeng`, N02 B1) but 2D has **no** nation sheets and already falls back to the
   generic Ukrainian sheet (N03 §2, M5). Converting them would make 3D diverge from
   2D; adding them is an **owner decision**, not part of this minimal plan.
4. Hall sheets exist for all 10 nations, but this plan changes only slot-0 Russia's
   starting hall (owner directive). Other nation halls are out of scope; note that
   `bavcen`/`swecen` donor meshes exist (N02 A2) if the owner later broadens scope.

---

## 6. (e) License / provenance note for CREDITS (ready-to-add text)

Target: `variant3d/CREDITS.md` (mirror the `app/CREDITS.md:1-5` private-use stance and
`README.md:220-224` license block). No CREDITS edit was made by N06.

```markdown
## Nation-specific derived 3D art (N06 additive conversion)
- `data/actors/buildings/rus/ruscen.osm` + `data/materials/buildings/rus/ruscen.dds`
  -> `variant3d/assets/models/obj/ruscen.obj` (+ `.mtl`) and `tex/ruscen.png`,
  produced offline by `tools/convert_models.py` (first IDP2 frame -> OBJ; DDS -> PNG,
  garbage alpha dropped).
- `data/actors/units/pea{rus,ukr,pol,aus,eng,spa,tur,sco}.oss` with the matching
  `data/materials/units/pea*.dds` -> `obj/pea*.obj` + `tex/pea*.png`; each nation's
  `data/animations/aaf/pea*.aaf` -> flat-root skin JSON under `assets/models/skin/`
  via `tools/convert_skins.py`.
These are DERIVED outputs (vertex/UV/face lists and converted pixels with donor
citations in `assets/models/manifest.json`), NOT verbatim donor files: the donor
`.osm/.oss/.dds/.aaf` binaries stay in the private install, are read only as
text/bytes, and are never copied into the repo or executed. For private use of the
game owner on their own machine only; never share, publish or redistribute
(`README.md:220-224`, `app/CREDITS.md:1-5`, `docs/WAIVERS.md` compliance statement).
Geometry is a STATIC bind pose / flat-root morph PORT APPROXIMATION (donor bone parent
hierarchy unreadable); donor AAF frame ranges are read per nation from each donor AAF.
Visual donor parity is UNVERIFIED — no donor GPU A/B frame exists.
```

G24 compatibility: no donor pixels or binaries are added under `docs/`; the new files
are tool-generated derivatives under `assets/models/`, consistent with G24 Finding 1/3.
The existing G24 §2 flag about A11 donor-screenshot crops is unrelated and unchanged.

---

## 7. Blockers and UNVERIFIED register

| # | Item | Label / owner |
|---|---|---|
| B1 | `data.gd:1565-1568` `resolve_sid` rejects any sid absent from `UNITS`; naïve `NATION_UNITS.peasant -> pearus` is a no-op. | **OBSERVED blocker** — code owner (§4.3) |
| B2 | `world3d_entities.gd:sync()` uses raw `ed.sid` for `has_skin`/`pose_for`/`_morph_mesh` (`:2111, :2127-2142`): nation mesh with peaukr animation until fixed. | **OBSERVED blocker** — code owner (N03 M6) |
| B3 | Construction-stage and ghost art remain base-sid/Ukrainian-derived (`world3d_entities.gd:1875+`, `world3d_fx.gd:658-669`), even with `ruscen.obj`. Optional donor stage files confirmed (§1.4). | **OBSERVED partial fix** — asset + code owner |
| B4 | Donor `.oss` bone parent hierarchy unreadable; only flat-root skin exists (`convert_skins.py:62-63`, `anim3d.gd:66`, `world3d_entities.gd:194`). | **UNVERIFIED rig fidelity** — do not invent parent matrices |
| B5 | AAF frame ranges differ per nation (§1.3; `pearus` `k=486` vs 483); must come from each nation's own AAF via `convert_skins.py:208-227`. `convert_skins.py:219` skips actions whose `last >= k`. | **OBSERVED data / UNVERIFIED runtime behavior** — asset owner must verify exported `frames`/`donor` per sid |
| B6 | `ruscen` geometry/bbox differs materially from `ukrcen` (§1.1); footprint, ghost silhouette and collision relationship to the sim radius need a capture. | **UNVERIFIED visual** — QA owner |
| B7 | No Godot run, no runner job, no capture by this ticket (WAVE_G_CHARTER:31,169). Every visual outcome is UNVERIFIED; no donor-parity claim is made anywhere. | **UNVERIFIED — binding** |
| B8 | Line numbers shifted during concurrent Wave N/P edits; re-confirm before applying any hunk. | **OBSERVED process note** |
| B9 | Running `convert_models.py` without `--nation-art/--manifest-name` rewrites all 280 manifest entries (:559-561). Byte-identity depends on the text-insertion procedure (§3), not on re-running the tool. | **OBSERVED blocker** — asset owner |
| B10 | Bavaria/Sweden donor-correct peasants exist but 2D has no nation sheets; adding them creates 3D/2D divergence. | **UNVERIFIED visual / owner decision** |
| B11 | Donor silhouette/colour differences are inferred from byte-distinct assets; N02 B3 has no donor render. | **UNVERIFIED** — no pixel claim permitted |
| B12 | `peaukr.obj` would duplicate `peasant.obj` byte-for-byte as a derived output; alias-vs-duplicate is an asset-owner choice. | **DERIVED** — no blocker |

---

## 8. Scope / safety attestation

- Read-only: the only repository file written is this report. No `.gd`, `.json`, `.py`,
  asset, config, test, queue or Godot state was touched. No runner job was submitted
  (submit/cancel/unwedge/ack/reset none), no Godot was launched.
- Donor install was accessed **read-only** for existence, byte sizes, header bytes and
  text lines (`.actor`, `.prop`, `.aaf`); SHA-256 was computed in place. Throwaway probe
  scripts were written only to `%TEMP%\opencode` (outside the repo, A11/G24 precedent).
  No donor file was copied into the repo or executed.
- N01, N03, G24, N02 (which landed concurrently) and the charters were read in full.
  2D sheet names were enumerated from `app/assets/models/anim/` and the variant3d anim
  tree. All "OBSERVED" claims are direct reads this pass; "DERIVED" claims follow from
  the cited code/data chain; "UNVERIFIED" labels are not softened anywhere.

*End of N06 report. Design only — no conversion was run, no asset was generated, no code was edited.*
