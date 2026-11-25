---
id: BUILD-ART-CONV-01
owner: BUILD-ART-CONV-01 (tooling builder subagent)
role: "Extend the authoritative port model converter with the 108 donor construction-stage / scaffold entries; converter config only"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: DONE__CONVERTER_CONFIG_ONLY__NO_ASSETS__NO_RUNNER__NO_PARITY_CLAIM
scope: "Edited ONLY variant3d/tools/convert_models.py and this report. Donor READ-ONLY (bytes/struct/latin-1 reads; no donor binary run, no donor copy). No asset generated, no runner job, no Godot launch."
owns:
  - variant3d/tools/convert_models.py
  - docs/coord_swarm_2026-11-25/reports/BUILD_ART_CONV_01.md
backup: inbox/backup/convert_models.py.bak-BUILDARTCONV01 (19,701 bytes, SHA-256 E3E66199B71EEA7A6B7DB0DC3687634ABA8CFAAC1A1E73D3A07D4968F2A293DB, taken before first edit)
diff: "+96 / -3 lines in convert_models.py (1 new function + 3 additive main() seams; no reader/writer/format edit)"
labels: [observed, derived, UNVERIFIED, NO_VISUAL_PARITY]
---

# BUILD-ART-CONV-01 — converter config for donor construction-stage / scaffold meshes

> [!IMPORTANT]
> This ticket adds **only** an opt-in conversion table and name/texture
> overrides to `variant3d/tools/convert_models.py`. **No** `.obj` / `.mtl` /
> `.png` was generated, **no** manifest was written, **no** donor byte was
> copied into the repository, and **no** Godot runner or visual A/B was run.
> Every visual-parity statement remains **UNVERIFIED**.

## 1. Inputs read

| Input | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/BUILD_ART_01.md` (297 lines, read in full) | Authoritative ticket plan: §3.1 donor sid table, §4.2 feasibility, §5 ticket (a) gate criteria, §6 double count. |
| `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md` (191 lines, read in full) | Runtime resolver contract (`<sid><1..4>[a].obj`), 0 stage OBJs, open question Q1. |
| `variant3d/tools/convert_models.py` (473 lines, read in full, pre-edit) | Authoritative converter. `read_osm:74-99`, `read_mesh:102-107`, `write_obj:114-130`, `write_mtl:133-137`, `convert_texture:140-158`, `building_models:246-297`, `main:415-469`. |
| `app/tools/convert_models.py` | Confirmed non-authoritative (BUILD-ART-01 §4.1); not edited. |
| Donor `C:\Games\Cossacks 3\data\**` (read-only) | 12 actor files, 12 prop files, `ontagstates.inc`, `buildings.mat`, `actors.lib`, all 108 OSMs, `scaffold.dds`. |

## 2. Donor citations (all read-only, `C:\Games\Cossacks 3\data\`)

| Converted item | Donor `path:line` | What the line says |
|---|---|---|
| 48 parent stages `<base>1..4.osm` | `actors/buildings/ukr/ukrcen.actor:5-18` — `Name = ukrcen1.mesh` … `ukrcen4.mesh` at :5/:9/:13/:17, `LoadFromFile = …ukrcen1.osm` … `ukrcen4.osm` at **:6/:10/:14/:18** | Four live stage mesh slots; the same pattern at lines 6/10/14/18 was re-read for all 12 mapped actors (`ukrhou`, `ukrbar`, `ukrsta`, `ukrbla`, `ukraca`, `ukrart`, `ukrdip`, `commoneur\eursto`, `eurmil`, `eurmar`, `eurtow`). |
| Parent stages reuse the base albedo (no new building PNG) | `objects/buildings/ukrcen.prop:13-43` — `DefaultMaterialName = ukrcen` at **:14, :20, :24, :28, :32, :36, :40** | Same single non-scaffold material on all 7 mesh slots; verified for all 12 props. Drives `tex_name = <port sid>` on parent entries. |
| 48 attach stages `<base>1a..4a.osm` + 12 base scaffolds `<base>a.osm` | `objects/buildings/engcen.prop:72-112` — `BaseName = engcena` :86, `DefaultMeshName = engcena.mesh` :88, `Mesh[0]=engcena` :90, `Mesh[1..4]=engcen1a..4a` **:91-94**, `DefaultMaterialName = scaffold` **:97**, `Materials[0..4]=scaffold` :99-103 | Scaffold auto-child with the 7 mesh slots. The same `<base>a` child was found in all 12 props (e.g. `ukrcen.prop:88-97`, `eursto.prop:78-82`, `eurtow.prop:78-82`). |
| Stage suffix `1..4`, wall fold `1+stage div 3`, child `<stage>a.mesh` | `scripts/units/building.inc/ontagstates.inc:240-259` — stage 0..3 → 1..4 at **:242-245**, `bwall` fold at **:247-248**, `actor := …+IntToStr(stage)` :250, child `actor+'a.mesh'` **:256**, `scaffold` material :257, visible :258 | Governs which converted name the runtime asks for (implemented by BUILD-STAGES-01; unchanged here). |
| Completion child = `<base>a.mesh` | `scripts/units/building.inc/ontagstates.inc:112-127` — child `actor+'a.mesh'` **:118**, `detail` material :119-125, visible **:126** | Justifies the 12 base-scaffold entries; integration (ticket c) still has to act on it. |
| One shared scaffold texture | `materials/buildings/buildings.mat:528-529` — `Material.Name = scaffold` :528, `Material.Texture.image = …\constructor\scaffold.dds` **:529** (winter `scaffoldw` at :1546-1547 deliberately unused) | Drives `tex_name = "scaffold"` on all 60 attach/base entries and the single `scaffold.png` output in the later asset batch. |
| Confirmed real file | `materials/buildings/constructor/scaffold.dds` = 2,796,344 B | Donor texture exists; not copied. |
| Wall/gate exclusion | `actors/actors.lib:543` (`// walls`), `:654` (`eurswa_v1.actor`), `:657-658` (`eurswa_gate.actor`); BUILD_ART_01.md §3.2 | Mapping UNVERIFIED; `wal`/`gat` stay out of this table. |

**Read-only donor verification (fresh, this ticket):** all **108** intended OSMs
exist (48 parent + 48 attach + 12 base), **0 missing**, **0 non-IDP2** (first
4 bytes of each file read as `b"IDP2"`). 10 files are the known 660-byte
minimal IDP2 case (all 8 Ukrainian base scaffolds, `eurmara.osm`, and
`eurtow1a.osm`); they remain flagged, not treated as errors, per
BUILD-ART-01 risk R1.

## 3. Before → after (`variant3d/tools/convert_models.py`)

Backup baseline: `inbox/backup/convert_models.py.bak-BUILDARTCONV01` (SHA-256
matches the live file at backup time). `git diff --numstat`: **+96 / -3**.

| # | Before (backup) | After (live) | Change |
|---|---|---|---|
| 1 | No stage table (`unit_models:165`, `building_models:246`, `ship_models:300`, `env_models:328`) | `stage_models()` at **:300-381** | 108 model dicts: 12 sids × 4 parent (`<sid>1..4`), 12 × 4 attach (`<sid>1a..4a`), 12 base (`<sid>a`). Unique sids; `obj_name` = own sid; `tex_name` = base sid for parents, `scaffold` for all 60 attach/base entries. Donor citations inline. `kind="building"`, `directions=1`. |
| 2 | `main()` had only `--game` / `--out` | `--include-stages` at **:505-508** | Opt-in flag, default OFF. |
| 3 | `models = unit + building + ship + env` (:431-432) | append at **:521-523** | `if args.include_stages: models = models + stage_models(game)`. Base order/metadata untouched. |
| 4 | Hard-coded `sid + ".obj" / ".mtl" / ".png"` (:444-446) | overrides at **:535-539** | `obj_name = m.get("obj_name", sid) + ".obj"`, `mtl_name = m.get("obj_name", sid) + ".mtl"`, `tex_name = m.get("tex_name", sid) + ".png"`. Defaults preserve every existing name. |

**Not changed:** `read_oss`, `read_osm`, `read_mesh`, `write_obj`, `write_mtl`,
`convert_texture`, `unit_models`, `building_models`, `ship_models`,
`env_models` (all source-identical to backup — validated); winding, bbox
computation, manifest writing, exit-code policy. No wall/gate/death entries.
No `--include-stages` side effect on the default run.

## 4. Validation (static only)

```
python -m py_compile variant3d\tools\convert_models.py     # exit 0
```

`PYTHONPYCACHEPREFIX` was pointed at
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\pycache-BUILDARTCONV01`,
so py_compile wrote **no bytecode into the repo**. A pre-existing
`variant3d/tools/__pycache__/convert_models.cpython-314.pyc` dated
**2026-11-24** was observed and left untouched; no `.pyc` was created or
deleted by this ticket.

Read-only table check (module imported with `sys.dont_write_bytecode = True`,
donor accessed only by `os.path.exists` / 4-byte `IDP2` reads):

| Check | Result |
|---|---|
| Base table, backup vs live, full dict equality | **172 = 172, identical** |
| Base kinds | unit **62**, building **17**, env **93** |
| New stage entries | **108** (building 108) |
| Stage sid uniqueness | **108 unique / 108** |
| Category split | parent digit-suffixed **48**, attach/base `a`-suffixed **60** (= 48 attach + 12 base) |
| `tex_name` tally | `scaffold` **60**; base sids `cen/hou/bar/sta/bla/aca/art/dip/sto/mil/mar/tow` = **4 each** (48) |
| Collisions with the 172 base sids | **0** |
| Collisions with existing OBJ names on disk | **0** |
| Missing donor mesh / donor texture | **0 / 0** |
| Non-IDP2 donor mesh | **0** |
| Reader/writer/texture function source identical to backup | `read_oss`, `read_osm`, `read_mesh`, `write_obj`, `write_mtl`, `convert_texture` — **all identical** |
| `main()` diff | +13 / -4 lines, confined to the three seams above; no other statement changed |
| Default naming parity | `m.get("obj_name", sid) == sid` and `m.get("tex_name", sid) == sid` for all 172 base entries — **True** |

Independent count methods for the 108: (1) importing `stage_models()` and
counting the returned dicts; (2) filesystem enumeration of the exact 108
donor paths derived from the 12-family table. Both returned **108**, and the
sets agree with zero missing files.

**Not run here (deferred by ticket scope):** the converter's full
`--include-stages` execution, OBJ/MTL/PNG writes, 6-number bbox gate,
byte-for-byte hash gate on the 172 existing assets, Godot runner jobs, and
any visual A/B. Those belong to the asset batch (ticket b).

## 5. Remaining tickets (unchanged plan from BUILD-ART-01 §5)

1. **BUILD-ART-B — asset batch** (owns `variant3d/assets/models/obj/`, `tex/`,
   `manifest.json`): after this ticket's gate, run the converter **with**
   `--include-stages`. Expected: +108 `.obj`, +108 `.mtl`, 1 `tex/scaffold.png`,
   manifest **172 → 280**. Must verify SHA-256 of all 172 pre-existing assets
   unchanged, base sid bboxes unchanged, all 108 new OBJs load as `Mesh`, and
   no donor extension file appears in the repo. Flag the 10 known 660-byte
   cases.
2. **BUILD-ART-C — runtime integration** (owns
   `variant3d/scripts/world3d_entities.gd`, BUILD-STAGES-01 block only): read
   per-stage bbox from `_bbox[sid+suffix]`, resolve the new 108 OBJ names,
   make the scaffold child visible, use `<sid>a` at completion, stop the
   unconditional "no stage OBJ" telemetry, decide `gat` wall-rule handling,
   and re-apply player tint after a mesh swap. No frozen block may change.
3. **BUILD-ART-D — 64² runtime assertion** (new atom
   `variant3d/tests/t_build_stages.gd` + result JSON): runner status ok, exit
   0, stderr 0 bytes, `SCRIPT ERROR == 0`; atom-only, never merged with the
   currently red integrated `selftest.json`.

Ordering constraint remains **a → b → c → d**; no donor parity claim may be
made until ticket d plus a visual A/B exist.

## 6. Guards

- **Donor-copy guard:** no `.osm`, `.dds` or `.oss` file was copied into the
  repository by this ticket. Repo census after the edit: **0 `.osm`, 0 `.oss`**,
  **936 `.dds`** all pre-existing (newest mtime **2026-11-20**, before this
  ticket, mostly `app/assets/terrain/decals*`). Donor was read only via Python
  `bytes`/`struct`/`latin-1` and existence/magic probes; no donor executable
  was run.
- **Parity guard:** no visual parity is claimed. Donor stage geometry was
  never rendered; labels stay `UNVERIFIED` / `NO_VISUAL_PARITY` per
  `WAVE7_3D_VARIANT_CHARTER.md:29-38`. The converter's static bind-pose
  disclaimer in its module docstring remains in force.
- **Identity guard:** readers/writers and all pre-existing model tables are
  source-identical to the backup; only the opt-in flag path can change output.
- **Scope guard:** no generated asset, `world3d_entities.gd`, manifest, test,
  config or `app/**` file was edited.

## 7. Open questions (carried forward, not resolved here)

1. **Q1** — Should the completion scaffold (`<sid>a`) be visible, matching
   `ontagstates.inc:112-127`, or stay hidden/freed with a PORT APPROXIMATION
   label? Owner decision, ticket c.
2. **Q2** — Authoritative `wal` / `gat` stage actor remains UNVERIFIED
   (`actors.lib:543,654,657-658`; `eurswa_gate1/2.osm` unreferenced). No wall
   or gate entry added here.
3. **Q3** — Are the 660-byte IDP2 meshes intentional minimal LOD or empty
   placeholders? Header parse cannot answer; render test needed (affects 10
   of the 108, incl. `eurtow1a` / `eurmara`).
4. **Q4** — Should `gat` be folded to stages 1..2 like `wal` in
   `_build_stage_suffix()`? Not changed here.
5. **Q5** — Re-apply tint after a stage mesh swap, or assert identical
   surface counts? Ticket c.
6. **Q6** — Use the imported MTL from `scaffold.png` or an explicit port
   material? Donor engine-side shader/blend is UNVERIFIED.
7. **Q7** — Death stages (`_death1` / `_death2`, `debris.dds`) stay deferred;
   no port event supplies the 30+30-frame timing yet.
8. **Q8** — Per-stage bbox and hash gates can only be measured in ticket b;
   this ticket verified table structure, not converted output.

## 8. Summary

Extended the authoritative `variant3d/tools/convert_models.py` with an opt-in
`--include-stages` path and `stage_models()` registering exactly **108** donor
construction-stage/scaffold OSMs for **12** non-wall building sids: **48**
parent stages, **48** attach stages, **12** base scaffolds, plus the single
`constructor\scaffold.dds` texture mapping. Unique stage sids (`cen1`,
`cen1a`, …, `tow4a`, `cena`) avoid `_bbox` collisions; `tex_name` reuse avoids
duplicate PNGs. Backup taken at
`inbox/backup/convert_models.py.bak-BUILDARTCONV01`; diff **+96 / -3**;
`py_compile` exit 0; base table **172 = 172 identical**, new entries **108
unique**, **0** sid/OBJ collisions, **0** missing donor files, all readers and
writers source-identical. **No donor file copied, no asset generated, no
runner job, no visual parity claim, and no file other than the converter and
this report was edited.** Concurrent foreign changes visible in `git status`
were left untouched.

*End of BUILD-ART-CONV-01 report.*
