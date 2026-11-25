---
id: BUILD-ART-01
owner: BUILD-ART-01 (read-only planning worker)
role: "Plan the conversion of donor construction-stage / scaffold meshes for the 3D port; no implementation"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: PLAN_ONLY — NO_CODE_EDITS — NO_DONOR_COPIES — NO_RUNNER_JOBS — NO_VISUAL_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/struct/latin-1 reads only; no donor binary run)"
output: "docs/coord_swarm_2026-11-25/reports/BUILD_ART_01.md (exclusive output path)"
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION, NO_VISUAL_PARITY]
counts_verified: "Twice by independent methods — see section 6"
---

# BUILD-ART-01 — Plan: convert donor construction-stage / scaffold meshes for the 3D port

> [!IMPORTANT]
> This is a **plan only**. No source file, asset, manifest, test or config was
> edited. No donor byte was copied into the repository and no donor executable
> was run. No Godot/Blender/variant-runner job was submitted. Every parity
> statement stays **UNVERIFIED** until a visual A/B capture exists.

## 1. Sources

### 1.1 Prior reports read (all read-only)

| # | Path | Use |
|---|---|---|
| P1 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md` | Live selector (`floor(progress*4)`, wall fold, derived stage-4 clamp), hidden scaffold placeholder, **0 stage OBJ** measurement, 8 UNVERIFIED labels. |
| P2 | `docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md` | Donor 7-slot actor inventory, `engcen.prop:72-112` auto-child, `scaffold`/`debris` materials, 25-nation enumeration, death stages. |
| P3 | `docs/coord_swarm_2026-11-25/reports/DBUILD_02.md` | Independent second pass; C1–C7 refinements (ship dummy dead code, `stage=4` edge, mine asymmetry, integer-division smoke threshold, non-conforming meshes). |
| P4 | `docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md` | `.osm` IDP2 conversion feasibility, Table B2 row "Construction stages `_s1..s4` / `_dead` — BLOCKED", test ids T-V72-1/T-V72-5, no-invention governing rule. |

### 1.2 Port files inspected read-only

| Path | What was read |
|---|---|
| `variant3d/tools/convert_models.py` (473 lines) | **Authoritative port converter.** `read_osm:74-99`, `read_mesh:102-107`, `write_obj:114-130`, `write_mtl:133-137`, `convert_texture:140-158`, `building_models:246-297`, `main:415-469`. |
| `app/tools/convert_models.py` (368 lines) | Older copy; no `ship_models`, no V7-63 actor corrections. Confirmed non-authoritative for this plan. |
| `variant3d/assets/models/manifest.json` | 172 model entries; kinds env 93 / unit 62 / building 17; 17 building sids listed in §4.2. |
| `variant3d/assets/models/obj/**` | Fresh enumeration of all `.obj` names. |
| `variant3d/scripts/world3d_entities.gd` | `bind():334-403`, `_apply_tint():820-837`, `_mesh_info():922`, `add_building():1428-1460`, stage block `:248-266`, `:1559-1699`, call site `:1913`. |
| `variant3d/tests/t_entities3d.gd`, `variant3d/tests/fixtures/small_map_64.json`, `variant3d/selftest.json` | Atom pattern (stub game + self-exit + result JSON), 64² fixture keys, integrated-selftest state. |

### 1.3 Fresh donor reads (all read-only)

Path shorthand below: `C3\data\` = `C:\Games\Cossacks 3\data\`.

- `C3\actors\buildings\<25 nation dirs>\**\*.osm` — full recursive enumeration (3,423 parent `.osm`, 1,605 under `attach\`).
- 14 port-mapped actor families (§4.1), each checked for `base{1,2,3,4,_death1,_death2}.osm` and `attach\base{a,1a,2a,3a,4a,_death1a,_death2a}.osm` with byte sizes and IDP2 header fields.
- `C3\actors\buildings\ukr\ukrcen.actor` (28 lines, full), `C3\actors\buildings\commoneur\eurswa.actor` (28 lines, full), `C3\actors\buildings\commonrus\eurswa_gate.actor` (9 lines, full).
- `C3\objects\buildings\ukrcen.prop` (124 lines, full), `engcen.prop` (122 lines, full), plus material-name scan of the 12 mapped props.
- `C3\materials\buildings\buildings.mat:528-534,1546-1552` — `scaffold`→`constructor\scaffold.dds`, `debris`→`constructor\debris.dds` (and winter variants).
- `C3\actors\actors.lib:543,657` and wall actor cross-reference scan.

### 1.4 Labelling convention

**observed** = literal bytes / filesystem / repo text read this pass. **derived** = arithmetic or control flow that follows from observations. **inferred** = strong but indirect synthesis. **UNVERIFIED** = no readable evidence or no runtime/visual capture. Every load-bearing number is checked twice (§6).

## 2. Context — what BUILD-STAGES-01 left open

`BUILD_STAGES_01.md` shipped a donor-cited selector but measured **0** converted
stage/scaffold OBJs, so every under-construction building reuses its own base
mesh (PORT APPROXIMATION) and the scaffold child is a **hidden** structural
placeholder (`:19-24`, `:84-93`, `:128-149`). Its open question 1 asks exactly
this ticket's question: will an asset owner convert donor stage/attach OSMs into
`assets/models/obj/**`? Its resolver is already name-compatible:

| Resolver (live code) | Expected output name | Present today |
|---|---|---|
| `_stage_mesh_info(sid, suffix, false)` :1597 | `variant3d/assets/models/obj/<sid><suffix>.obj` (`cen1.obj` … `cen4.obj`) | **0** |
| `_stage_mesh_info(sid, suffix, true)` :1597 | `variant3d/assets/models/obj/<sid><suffix>a.obj` (`cen1a.obj` … `cen4a.obj`) | **0** |
| `bind()` availability probe :400-403 | `<sid>1.obj`, `<sid>a.obj` | **0** |

The converter is therefore the missing link, not the runtime selector.

## 3. Donor asset inventory

### 3.1 Port building sids that have real donor construction stages

The port converter's `building_models()` maps 14 building sids plus 3 mines.
Twelve of the 14 are **non-wall** buildings with a real 4-stage donor family;
they are the only sids this plan proposes to convert.

| Port sid | Donor actor folder / base | Parent stage OSMs (`data\actors\buildings\...`) | Scaffold attach stage OSMs (`...\attach\...`) | Base scaffold |
|---|---|---|---|---|
| `cen` | `ukr\ukrcen` | `ukrcen1/2/3/4.osm` (66,836 / 103,764 / 185,932 / 295,052 B) | `ukrcen1a/2a/3a/4a.osm` (166,652 / 268,940 / 349,452 / 409,172 B) | `ukrcena.osm` 660 B |
| `hou` | `ukr\ukrhou` | 53,332 / 66,468 / 115,540 / 163,868 | 135,412 / 149,828 / 169,972 / 177,772 | 660 B |
| `bar` | `ukr\ukrbar` | 32,740 / 39,076 / 59,268 / 217,468 | 175,196 / 181,668 / 199,804 / 225,732 | 660 B |
| `sta` | `ukr\ukrsta` | 65,292 / 94,612 / 111,188 / 233,068 | 95,740 / 154,116 / 193,508 / 157,428 | 660 B |
| `bla` | `ukr\ukrbla` | 161,964 / 203,516 / 263,668 / 398,676 | 131,796 / 148,052 / 155,316 / 197,884 | 660 B |
| `aca` | `ukr\ukraca` | 132,756 / 377,892 / 503,940 / 709,764 | 258,436 / 354,900 / 440,700 / 535,404 | 660 B |
| `art` | `ukr\ukrart` | 56,948 / 78,724 / 100,652 / 172,340 | 165,284 / 246,228 / 244,684 / 266,652 | 660 B |
| `dip` | `ukr\ukrdip` | 95,940 / 223,084 / 361,940 / 435,972 | 182,972 / 206,876 / 273,676 / 280,612 | 660 B |
| `sto` | `commoneur\eursto` | 22,660 / 36,468 / 40,196 / 53,700 | 45,196 / 115,156 / 76,428 / 93,756 | `eurstoa.osm` 41,836 B |
| `mil` | `commoneur\eurmil` | 29,316 / 47,604 / 82,924 / 145,780 | 136,060 / 200,324 / 185,388 / 195,556 | `eurmila.osm` 96,740 B |
| `mar` | `commoneur\eurmar` | 103,788 / 131,868 / 173,148 / 270,196 | 142,492 / 229,900 / 194,268 / 204,620 | `eurmara.osm` 660 B |
| `tow` | `commoneur\eurtow` | 16,852 / 53,172 / 56,452 / 75,388 | **660** / 164,908 / 156,404 / 167,620 | `eurtowa.osm` 53,948 B |

**Observed:** all 48 parent and all 48 attach stage files exist, all begin with
`IDP2` (sampled `ukrcen1.osm`, `ukrcen1a.osm`, `eursto4.osm`, `eursto4a.osm`).
`ukrcen.actor:1-28` lists the same seven mesh slots as `engcen.actor`; the
port's other 11 families follow the same on-disk pattern. Stage meshes use the
**same material as the base mesh** — `ukrcen.prop:13-43` sets `ukrcen` for all
seven slots; the same single non-scaffold material was observed for all 12
mapped props. Therefore stage OBJs can reuse the existing `<sid>.png` and need
**no new building texture**.

**Observed caveat:** a 660-byte IDP2 is a valid but minimal mesh — header parse
gives `num_verts=8`, `num_uv=12`, `num_tris=12`, `num_frames=1`, `ofs_end=660`.
`eurtow1a.osm` and `eurmara.osm` are of this class; they are small geometry, not
parse failures, but their visual role is **UNVERIFIED**.

### 3.2 Wall / gate — deliberately excluded from the asset batch

| Port sid | Map | Observed donor state | Verdict |
|---|---|---|---|
| `wal` | `commoneur\eurswa` | `eurswa1.osm` / `eurswa2.osm` = 660 B (8 verts); `attach\eurswaa,1a,2a,3a,4a` also 660 B. `eurswa.prop:9` actually names `eurswa_v1.actor`, whose real stages are `eurswa_v11/12.osm` in `commonrus`. | **UNVERIFIED mapping** — do not convert degenerate placeholders; owner must pick the authoritative wall actor. |
| `gat` | `commonrus\eurswa_gate` | `eurswa_gate1.osm` / `2.osm` are real (148,212 B, 3,731 verts each) but **no `.actor` references them** (scan of all `actors\buildings\**\*.actor` = 0 hits); `eurswa_gate.actor` has only LOD base meshes; `commonrus\attach\` has **no** `eurswa_gate*` files. | **UNVERIFIED** — real unused files are not proof of a live stage. |

Additionally, the live wall rule in `world3d_entities.gd:1583` checks only
`sid == "wal"`, so `gat` would be assigned suffixes 1..4 if stage art were
added. This gap is carried into the integration ticket as an explicit decision,
not silently changed.

### 3.3 Death stages — inventoried but out of scope

Each of the 12 families has `_death1.osm` / `_death2.osm` (24 parent files) and
`attach\..._death1a/_death2a.osm` (24 attach files), with `debris` material
(`buildings.mat:533-534` → `constructor\debris.dds` 699,192 B). DBUILD-01 §3 and
BUILD-STAGES-01 §7 item 7 leave these MISSING. **This plan does not convert
them**; no `debris.png` is produced and no 30+30-frame port event exists yet.
Some death attach files are themselves 660 B (`eursto_death1a/2a`,
`eurtow_death1a/2a`, wall attach).

### 3.4 Exact donor file set required (construction only)

For the 12 non-wall sids:

- **48** parent stage OSMs: `<base>1.osm` … `<base>4.osm`.
- **48** attach stage OSMs: `attach\<base>1a.osm` … `<base>4a.osm`.
- **12** base attach OSMs: `attach\<base>a.osm` (needed for the donor's
  completion state, `ontagstates.inc:112-127`).
- **1** texture: `C3\materials\buildings\constructor\scaffold.dds` (2,796,344 B).

**Total: 108 donor `.osm` + 1 donor `.dds`.** No donor file is copied verbatim
into the repo; only derived `.obj` / `.mtl` / `.png` outputs are written.

## 4. Tool feasibility

### 4.1 Filename correction (observed)

The task names `convert_models_3d.py`. **No such file exists.** A recursive
`*.py` search across the repository returned exactly two model converters:
`variant3d/tools/convert_models.py` (473 lines, V7-63 enhanced) and
`app/tools/convert_models.py` (368 lines, older). The port-authoritative tool is
the `variant3d` copy — it owns the manifest that `world3d_entities.gd:363-377`
reads and already includes `dip`/`wal`/`gat`/ships. All feasibility below refers
to `variant3d/tools/convert_models.py`.

### 4.2 No new format work is needed

| Requirement | Existing code | Verdict |
|---|---|---|
| Read donor stage/attach geometry | `read_osm():74-99` parses any IDP2 via longs 12/13/14 and swaps winding `(0,2,1)`; `read_mesh():102-107` dispatches on `IDP2`. Sampled stage/attach files are IDP2. | **FEASIBLE — no reader change** |
| Write port mesh | `write_obj():114-130` emits `v`/`vt`/`f` with `mtllib`; `write_mtl():133-137` points at `..\tex\<sid>.png`. Same output contract as the 172 existing base OBJs. | **FEASIBLE — no writer change** |
| Scaffold texture | `convert_texture():140-158` converts DDS→PNG with `force_opaque=True` for `kind="building"`; portable to `scaffold.dds`. | **FEASIBLE — no converter change** |
| Per-stage bbox | `main():451-460` computes bbox from the converted verts and stores it in the manifest entry. | **FEASIBLE — fixes BUILD-STAGES-01 UNVERIFIED item 4** |
| Naming / texture reuse | `main():444-449` hard-codes `sid + ".obj"`, `sid + ".mtl"`, `sid + ".png"`. Stage outputs need `<sid><suffix>.obj` while reusing `<sid>.png`; scaffold outputs need `<sid><suffix>a.obj` while reusing one `scaffold.png`. | **ONE CONFIG/NAME CHANGE REQUIRED** |
| Manifest uniqueness | `world3d_entities.gd:366-370` keys `_bbox` by `sid`; two entries with `sid="cen"` would overwrite the base bbox. New entries must use **unique** sids (`cen1`, `cen1a`, …). | **Design constraint on the same change** |

**Verdict:** the existing tool can convert all 108 OSMs with **zero new binary
format work**. The only code work is an additive model table plus optional
`obj_name` / `tex_name` overrides in `main()` (defaults preserve all existing
behaviour). This matches V72 Table A (static buildings FEASIBLE) and narrows its
Table B2 "construction stages — BLOCKED" row to a *conversion backlog*, not a
data gap. Labels: reader/writer feasibility **observed**; effort estimate
**derived**; visual result **UNVERIFIED**.

### 4.3 Port asset state before the batch (fresh measurement)

- `variant3d/assets/models/obj/**`: **172** `.obj` files, exactly equal to the
  **172** manifest entries (set equality confirmed).
- Port building-kind manifest sids: **17** = 14 named building sids + 3 mines;
  `ca`, `ba2`, `tem`, `por`, `sga`, `coa`, `gol`, `iro`, `wga`, `wwa`, `bld`
  have **no** base OBJ and are not candidates.
- For the 12 target sids, **0 of 96** required stage/scaffold OBJ names exist.
  This independently reproduces BUILD_STAGES_01 §2 ("0 hits").
- `variant3d/assets/models/tex/scaffold.png` and `debris.png` are **absent**;
  `cen.png` exists (4,307,502 B).

## 5. Ordered ticket plan

Four tickets, strictly ordered. No ticket authorises a donor copy, a runner job
during planning, or a parity claim.

| # | Ticket / owning file(s) | Change | Gate criteria | Labels |
|---|---|---|---|---|
| **a** | **BUILD-ART-A — converter config** — `variant3d/tools/convert_models.py` only | Add `stage_models(game)` returning 108 model-dict entries for the 12 sids in §3.1: unique `sid` = `<port_sid><suffix>` and `<port_sid><suffix>a`; `obj_name` = that sid; `tex_name` = base sid for parent stages, `scaffold` for every attach entry; `texture` = the mapped base DDS or `constructor\scaffold.dds`; `kind="building"`. Add optional `obj_name`/`tex_name` in `main():444-449` (defaults = `sid`). Add `--include-stages` flag; when set, `models = base_models + stage_models(game)`. **No reader, writer, winding or format edit.** No wall/gate/death entries. | (1) Table evaluates to **108** entries with **108** unique sids and **0** missing donor paths (two independent counts). (2) `read_osm`/`write_obj` bodies byte-identical to current file. (3) With flag off, full regeneration reproduces the existing 172 entries byte-for-byte (manifest base entries + base OBJ/MTL/PNG hashes). (4) All 108 new entries carry a 6-number bbox; the 2 known 8-vert cases (`eurtow1a`, `eurmara`) are flagged in the ticket log, not treated as errors. | observed / derived; visual UNVERIFIED |
| **b** | **BUILD-ART-B — asset batch** — outputs under `variant3d/assets/models/` (owned dirs: `obj/`, `tex/`, `manifest.json`) | After ticket (a) is merged and gated, run the converter once **with** `--include-stages` into the existing port model root. Exact new outputs: **48** `<sid>{1..4}.obj` + **48** `.mtl`; **48** `<sid>{1..4}a.obj` + **48** `.mtl`; **12** `<sid>a.obj` + **12** `.mtl`; **1** `tex/scaffold.png`; manifest grows **172 → 280** entries. No death OBJs, no `debris.png`, no wall/gate entries. | (1) File counts exact: 108 new `.obj`, 108 new `.mtl`, 1 new `.png`, manifest 280 entries. (2) Every new `.obj` starts with the converter header, has `mtllib`, `o model`, ≥1 `v`, ≥1 `vt`, ≥1 `f`; Godot `ResourceLoader.exists()` **and** `load()` non-null as `Mesh` for all 108. (3) SHA-256 of all 172 pre-existing `.obj`/`.mtl`/`.png` unchanged. (4) `git status` shows no donor-extension file (`.osm`, `.dds`, `.oss`) anywhere in the repo. (5) Manifest base sids `cen`, `hou`, … keep their original bbox values. | observed; parity UNVERIFIED until A/B |
| **c** | **BUILD-ART-C — runtime integration** — `variant3d/scripts/world3d_entities.gd` only, restricted to the BUILD-STAGES-01 block (`:248-266`, `:394-403`, `:464-472`, `:1559-1699`, `:1913`) | Replace approximation branches: (i) `_stage_mesh_info()` reads per-stage bbox from `_bbox[sid+suffix]` when present, falling back to base sid, and uses the new 108 OBJ names; (ii) `_sync_building_stages()` binds a real stage mesh when resolved and keeps the labelled base fallback otherwise; (iii) scaffold child becomes **visible** with `<sid><suffix>a` mesh when art resolves, and at `finished=true` uses `<sid>a` instead of being freed (donor `ontagstates.inc:112-127,253-259`); (iv) update `BUILD_STAGE_LABEL`/`BUILD_SCAFFOLD_LABEL` and telemetry to stop claiming "no stage OBJ" unconditionally; (v) decide and document `gat` wall-rule handling in `_build_stage_suffix():1583` (leave 4-stage + UNVERIFIED, or fold to 1..2). Re-apply or assert the player tint after a mesh swap (surface overrides are set for the **base** mesh in `_apply_tint():833-837`). | (1) `add_building`, `_attach_rotor`, `_rotor_material`, MILLFIX rotor block, DECOR constant block and all public signatures unchanged (line-slice diff vs backup). (2) Parse-only runner smoke: exit 0, stderr 0 bytes, `SCRIPT ERROR == 0`. (3) `stats.build_stage_obj_hits > 0` and `stats.build_scaffold_obj_hits > 0` on art-bearing sids; sids without art still report `PORT APPROXIMATION`, never a silent base swap. (4) No donor file read at runtime; no new numeric constant. | derived; visual UNVERIFIED |
| **d** | **BUILD-ART-D — 64² runtime assertion** — new atom `variant3d/tests/t_build_stages.gd` (+ its `.uid`), result `variant3d/tests/results/t_build_stages.json`; fixture reused: `variant3d/tests/fixtures/small_map_64.json` | `extends SceneTree`, self-exiting via `call_deferred("quit", …)`, stub game pattern from `t_entities3d.gd:26-49` with `map_w = map_h = 64`, seed `20261113`, `render_mode=3d`. Bind `World3DEntities`, add `cen` entities at `progress/build_time` 0.0/0.3/0.6/0.9 and `wal`/`gat` at 0.0/0.9, call `sync(0.0)`, write PASS/FAIL JSON. | Assert: `build_stage_suffix` = 1,2,3,4 for `cen` and 1,2 for wall-folded sids; `build_stage_source == "obj_stage_zup_bbox_normalised"` (not `base_mesh_port_approximation`) where art exists; scaffold child exists, `visible == true`, `scaffold_source == "stage_scaffold_obj"`; finished `cen` uses `<sid>a` scaffold; `_bbox` has `cen1..cen4` and base `cen` unchanged; `stats.build_stage_obj_hits >= 4`, `stats.build_scaffold_obj_hits >= 4`. Runner ticket `buildart01-runtime`: status ok, exit 0, stderr 0 bytes, `SCRIPT ERROR == 0`, result JSON `passed: true`. **Atom-only** — not merged with the currently red integrated `selftest.json` (`passed:false`, build step). No pixel/visual assertion. | observed (harness pattern) / derived (expected values); visual UNVERIFIED |

**Ordering constraint:** (a) → (b) → (c) → (d). Ticket (b) must not be run
before (a)'s hash/identity gate, and (c) must not be merged before (b)'s asset
counts are measured. If any gate fails, stop; do not paper over it with a
fallback that claims donor parity.

## 6. Double verification of counts

Every count below was produced twice by independent methods in this pass.

| Count | Method 1 | Method 2 | Agreement |
|---:|---|---|---|
| 172 port OBJ files | `Get-ChildItem -Recurse variant3d\assets\models\obj -Filter *.obj` → 172 | `os.listdir` set vs manifest `models` length 172, **set equality true** | **YES** |
| 17 port building-kind sids | `manifest.json` `kind=="building"` tally → 17 | Explicit list (`cen,hou,bar,sta,bla,aca,art,sto,mil,mar,tow,mine_gold,mine_iron,mine_coal,dip,wal,gat`) → 17 | **YES** |
| 48 parent stage OSMs (12 sids × 4) | Explicit `<base>{1,2,3,4}.osm` existence table → 48 | `glob("<base>[1-4].osm")` filtered to the 12 bases → 48, **sorted sets equal** | **YES** |
| 48 attach stage OSMs | Explicit `attach\<base>{1a..4a}.osm` table → 48 | `glob(attach\*.osm)` filtered to the 48 wanted stems → 48, **sorted sets equal** | **YES** |
| 12 base attach OSMs | Explicit `attach\<base>a.osm` table → 12 | Glob filtered to the 12 wanted stems → 12, **sorted sets equal** | **YES** |
| 96 needed OBJ names / 0 present | 12 sids × 8 suffixes = 96 names checked against `os.listdir(obj)` → 0 hits | BUILD_STAGES_01 §2 independently reports 0 hits for its suffix probe | **YES** |
| 25 donor building nation dirs | `Get-ChildItem -Directory data\actors\buildings` → 25 | DBUILD-01 §2.4 / DBUILD-02 D10 enumeration → 25 | **YES** |
| 3,423 parent / 1,605 attach donor `.osm` | Recursive `Get-ChildItem` under `actors\buildings` | DBUILD-01/02 independently enumerate the same tree (counts not restated there; **not a second numeric read**) | **PARTIAL — see risks R8** |

Labels: all "YES" rows are **observed**; the final row is **UNVERIFIED** as a
double numeric confirmation (first count observed, second source only corroborates
the tree structure).

## 7. Risks

| # | Risk | Label | Mitigation / gate |
|---|---|---|---|
| R1 | 660-byte IDP2 meshes (`eurswa1/2`, all `eurswa*` attach, `eurtow1a`, `eurmara`, several death attach) are 8-vert placeholders. Converting them yields degenerate silhouettes, not visual stages. | observed (byte/header) | Ticket (a) logs them explicitly; ticket (b) gate flags them; ticket (d) never asserts art for `wal`/`gat`. |
| R2 | Wall/gate donor mapping is ambiguous: port `wal` base is `commoneur\eurswa` but `eurswa.prop:9` names `eurswa_v1.actor`; `eurswa_gate1/2.osm` are real but unreferenced by any actor; no gate attach files exist. | observed + inferred | Exclude walls from batch (a); owner decision recorded in open question Q2. |
| R3 | Manifest key collision: duplicate `sid="cen"` would overwrite `_bbox["cen"]` in `bind():366-370`. | derived | Unique stage sids mandated in (a); gate (b) item (5). |
| R4 | Full regeneration rewrites the 172 existing base assets. | derived | Hash gate (a) item (3) and (b) item (3). |
| R5 | Texture duplication: without `tex_name` override, 108 duplicate PNGs (~hundreds of MB) would be emitted. | derived | `tex_name` override is part of (a); 1 `scaffold.png` only in (b). |
| R6 | Per-stage bbox is only useful if the runtime reads it; otherwise `_stage_mesh_info():1601` keeps normalising with the base bbox. | derived | Ticket (c) item (i) + assertion (d). |
| R7 | Player tint is applied as surface overrides for the **base** mesh (`_apply_tint():833-837`); swapping to a stage mesh with a different surface count may drop tint. | derived from code, visual effect UNVERIFIED | Ticket (c) must re-apply or assert surface count; otherwise label PORT APPROXIMATION. |
| R8 | Donor `.osm` census (3,423 / 1,605) has only one fresh numeric read in this pass. | UNVERIFIED as a double read | Not used as a gate; does not affect the 108-file set. |
| R9 | `scaffold.dds` alpha/blend semantics unknown; `force_opaque=True` follows the existing building policy but may not match the donor material. | UNVERIFIED | Visual A/B required; no material invention. |
| R10 | Integrated `variant3d/selftest.json` is currently `passed:false` (`build` step). | observed | Ticket (d) is an isolated atom, never a claim that the integrated gate is green. |
| R11 | Port progress counter `progress/build_time` ≠ donor `hp/maxhp`; stage boundaries may occur at different sim moments. | UNVERIFIED (carried from BUILD-STAGES-01 §7.3) | Out of scope of art conversion; keep label. |
| R12 | No donor GPU capture is possible here; `.osm` visual content was never rendered. | observed / UNVERIFIED | **No parity claim until visual A/B** (V72 governing rule, `WAVE7_3D_VARIANT_CHARTER.md:29-38`). |
| R13 | Death stages remain missing; a later ticket would need 30+30-frame timing and `debris.dds`, and several death attach meshes are 660 B. | observed | Explicitly deferred in §3.3. |

## 8. Open questions

1. **Q1 — Completion scaffold visibility.** Donor makes the base scaffold
   (`<sid>a`) visible at completion (`ontagstates.inc:112-127`), while the port
   currently frees the child. Should ticket (c) reproduce the visible
   completion scaffold, or keep the hidden/freed path and label it PORT
   APPROXIMATION? Requires an owner decision, not a conversion decision.
2. **Q2 — Authoritative wall actor.** For `wal`, convert `eurswa1/2` (attached
   to port base, but 660 B), `eurswa_v11/12` (named by `eurswa.prop:9`), or
   nothing? For `gat`, are the unreferenced `eurswa_gate1/2.osm` safe to use?
3. **Q3 — 660-byte meshes.** Are they intentional minimal LOD geometry or
   empty placeholders? A render test is needed; header parse alone cannot
   answer (UNVERIFIED).
4. **Q4 — `gat` wall rule.** Should `_build_stage_suffix():1583` fold `gat` to
   1..2 as well, or is the current `wal`-only check deliberate?
5. **Q5 — Tint after swap.** Re-apply `_apply_tint()` after a stage mesh swap,
   or assert identical surface counts and leave as-is?
6. **Q6 — Scaffold material.** Use the imported MTL from `scaffold.png`, or
   an explicit port material? Donor `scaffold` is a named material
   (`buildings.mat:528-529`), but its shader/blend is engine-side.
7. **Q7 — Death follow-up.** If `_death1/_death2` are added later, which port
   event supplies the donor 30+30-frame timing, and should the 660 B death
   attach meshes be skipped?
8. **Q8 — Runner flags for the atom.** Exact `--script` / `--config`
   combination for the 64² atom is UNVERIFIED until ticket (d) is executed;
   the gate is defined by result JSON + exit/stderr, not by a presumed flag.

## 9. Summary

- **Feasibility:** the port's `variant3d/tools/convert_models.py` already reads
  IDP2 `.osm` and writes the exact OBJ/MTL/PNG contract the runtime consumes;
  **no new binary format work** is required. Only an additive model table and
  name/texture overrides are needed (ticket a).
- **Exact donor set:** for the 12 non-wall building sids — **108** `.osm`
  (48 parent stages + 48 attach stages + 12 base scaffolds) plus **1**
  `scaffold.dds`. Wall/gate and all death stages are explicitly excluded and
  labelled UNVERIFIED.
- **Exact outputs:** 108 `.obj` + 108 `.mtl` + 1 `scaffold.png`, manifest
  172 → 280; files named `<sid>1..4.obj`, `<sid>1..4a.obj`, `<sid>a.obj` —
  which the existing runtime resolver already probes.
- **Integration:** `_stage_mesh_info()` / `_sync_building_stages()` in
  `variant3d/scripts/world3d_entities.gd` replace base-mesh and hidden-scaffold
  fallbacks with real art where present, keep PORT APPROXIMATION elsewhere, and
  preserve every frozen block and public API.
- **Verification:** a new isolated 64² atom asserts suffix 1/2/3/4, wall fold,
  real mesh sources, visible stage-scoped scaffold, per-stage bbox and telemetry
  with exit 0 / stderr 0 / `SCRIPT ERROR == 0`.
- **Honesty:** no donor bytes were copied, no file other than this report was
  edited, no runner job was submitted, and **no visual parity is claimed** until
  a donor-vs-port A/B capture is performed.

*End of BUILD-ART-01 report. Read-only planning; every count verified twice; all uncertainties labelled.*
