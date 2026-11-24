---
id: V7-72
owner: V7-72
scope: "generate the 56 missing .import sidecars for V7-63's new OBJ/PNG via variant3d's godot_runner.py only; measure runtime obj_available with a deleted temporary probe"
date: 2026-11-24
status: DELIVERED
mode: "no .gd / manifest.json / app/ / config / tests left modified; no direct godot invocation; no git operations; only new .import sidecars under variant3d/assets/models/{obj,tex}/ + this report"
---

# V7-72 — Godot import of the 56 V7-63 donor-derived models

## 1. Task and baseline

V7-63 (`docs/coord_swarm_2026-11-24/reports/V763_missing_models.md:188-193`) added 56
OBJ + 56 MTL + 56 PNG + 56 manifest entries but no `.import` sidecars, so
`world3d_entities.gd:124-127` (`ResourceLoader.exists(OBJ_DIR + sid + ".obj")`)
could not count the new sids as available. This ticket closes exactly that gap.

Measured BEFORE any Godot run (`Get-ChildItem` on the two asset directories):

| Path | Files total | OBJ | MTL | PNG | `.obj.import` | `.png.import` |
|---|---|---|---|---|---|---|
| `variant3d/assets/models/obj/` | 460 | 172 | 172 | — | **116** | — |
| `variant3d/assets/models/tex/` | 288 | — | — | 172 | — | **116** |

So 172 source assets were present but only 116 had import metadata — a deficit
of exactly **56** in each directory, matching V7-63's §5 table.

## 2. Godot CLI syntax check (before the import)

Godot was **never invoked directly**. Only `variant3d/tools/godot_runner.py` was
used, and its own job log proves the engine build:
`Godot Engine v4.7.2.stable.official.ed1daf0bf`
(e.g. `variant3d/.godot_queue/results/00000000_v70-baseline-selftest/stdout.txt:1`).

CLI help was obtained through the runner (job `v772-cli-help`, ticket **98**,
exit 0):

```powershell
python variant3d\tools\godot_runner.py run --id v772-cli-help --timeout 60 -- --headless --help
```

Relevant 4.7.2 help lines
(`variant3d/.godot_queue/results/00000098_v772-cli-help/stdout.txt`):

* `:29` `--quit` — Quit after the first iteration.
* `:32` `--path <directory>` — Path to a project (must contain `project.godot`).
* `:47` `--headless` — headless mode.
* `:23` `-e, --editor` — Start the editor instead of running the scene.
* `:103` `--import` — **"Starts the editor, waits for any resources to be imported, and then quits."** (editor-only flag)

`--import` is the purpose-built headless import form; the runner's own history
already contains a successful 4.7.2 import with it (ticket **4**,
`v70-import-bootstrap-r3`, exit 0, 133.4 s). This is the syntax used below; the
`--editor --quit` example is equally valid in 4.7.2 but is the general editor
startup path, not the dedicated import command.

## 3. Exact import command and job id

```powershell
python variant3d\tools\godot_runner.py run --id v772-editor-import --timeout 600 -- --headless --path variant3d --import
```

* **Job id:** `v772-editor-import`
* **Ticket:** **104**
* **Result:** `status=ok`, `exit=0`, wait 118.79 s, run **22.41 s** (timeout 600 s)
* **Engine argv:** `--headless --path variant3d --import`
* Result files: `variant3d/.godot_queue/results/00000104.json` and
  `variant3d/.godot_queue/results/00000104_v772-editor-import/{stdout,stderr}.txt`

The import log ends with two `reimport` phases: "Started (Re)Importing Assets
(**112 steps**)" and "Finalizing Asset Import..." — exactly
56 new OBJ + 56 new PNG. Sample log entries name the V7-63 sids directly
(`sipahi.obj`, `sco_highlandersword.obj`, `reiter.obj`, `raidersco.obj`,
`priest.obj`, `pope.obj`, `pikemansco.obj`, `pikeman18.obj`, `pandur.obj`,
`padre.obj`, `officersco.obj`, `officer18.obj`, `musketeersco.obj`,
`musketeer.obj`, `musk18.obj`, `multicannon.obj`, `mullah.obj`, `mortar.obj`).

## 4. Before / after counts

| Metric | Before | After | Delta |
|---|---|---|---|
| `obj/` files total | 460 | **516** | +56 |
| `obj/` `.obj.import` | 116 | **172** | **+56** |
| `obj/` `.mtl` | 172 | 172 | 0 |
| `obj/` `.obj` | 172 | 172 | 0 |
| `tex/` files total | 288 | **344** | +56 |
| `tex/` `.png.import` | 116 | **172** | **+56** |
| `tex/` `.png` | 172 | 172 | 0 |

Per-sid check of all 56 V7-63 sids (46 units + 7 ships + 3 buildings):
**56 / 56** have `<sid>.obj.import` and **56 / 56** have `<sid>.png.import`;
**0 missing**. A sample sidecar (`obj/yacht.obj.import`) reads
`importer="wavefront_obj"`, `type="Mesh"`, pointing at
`res://.godot/imported/yacht.obj-de2f6270066aa6fb556fb68c0e20ecfc.mesh`.
The corresponding `.mesh` caches exist for sampled new sids
(`officer18`, `musk18`, `yacht`, `frigate`, `dip`, `wal`, `gat`: 1 cache each).

No source OBJ/MTL/PNG was modified by this ticket; only the 112 new sidecars
(and Godot's own `.godot/imported/` cache) were written.

## 5. Runtime `obj_available` measurement

A temporary probe `variant3d/tests/_v772_obj_probe.gd` loaded the real
`res://scripts/world3d_entities.gd`, instantiated it under a stub game, called
`bind()`, and used the **same** `ResourceLoader.exists(OBJ_DIR + sid + ".obj")`
check as the module. It also called `load()` on five new assets. Run only
through the runner:

```powershell
python variant3d\tools\godot_runner.py run --id v772-obj-available-probe --timeout 180 -- --headless --path variant3d --script res://tests/_v772_obj_probe.gd
```

* **Job id:** `v772-obj-available-probe`, ticket **113**, `status=ok`, `exit=0`, run 2.91 s.
* Result: `variant3d/.godot_queue/results/00000113_v772-obj-available-probe/stdout.txt`.

Measured payload:

```json
{"bbox_sids":172,"glb_available":0,"load_sample_bad":[],
 "load_sample_ok":["officer18","musk18","yacht","dip","gat"],
 "manifest_sids":172,"new_sids_available":56,"new_sids_checked":56,
 "new_sids_missing":[],"obj_available":172,"probe":"v772_obj_available"}
```

Interpretation: the entity module now reports
`obj_available = 172` (was at most 116 before import), **all 56 new sids are
`true`**, and five sampled new assets actually `load()` as a `Mesh`.
This answers the V7-63 open question: no manual editor step is required.

The probe file was **deleted** afterwards: `variant3d/tests/_v772_obj_probe*`
matches 0 files. No probe result JSON was written into the repo; the output
lives only in the runner's spool under `variant3d/.godot_queue/results/`.
`stderr` contained only the module's pre-existing static-pose warning
(`world3d_entities.gd:165`), no error.

## 6. Import errors

None. `variant3d/.godot_queue/results/00000104_v772-editor-import/stderr.txt`
is **0 bytes**; the import stdout has **0** lines matching
`ERROR|error|Failed|failed|WARNING|Cannot|could not`. Runner status for ticket
104 is `ok` with exit 0. The probe's only stderr output was the expected
`STATIC BIND POSE - PORT APPROXIMATION - NOT DONOR PARITY` warning, unrelated
to importing.

## 7. Open questions

1. **GLB lane still empty.** `glb_available = 0`; the V7-8 `.glb` path is out of scope.
2. **2 of 81 roster ids remain cube fallbacks** (`bar18`, `dock`) — unchanged by this
   import; see V7-63 §6. Importing cannot fix missing source meshes.
3. **P0-1 unaffected.** `obj_available` measures asset presence, not that the live
   sim calls `add_unit`/`add_building`; wiring remains a separate integration ticket.
4. **Static parity label unchanged.** Imported meshes are static bind poses /
   port approximations, not donor-faithful animation.
