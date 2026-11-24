# CossacksGodot — 3D Skirmish Variant (`variant3d/`)

This directory is a **full, independent Godot 4.x project** that duplicates every
2D mechanic of the shipping `app/` port, but is the home of the 3D rendering
branch. It was created mechanically by V7-0 (scaffold) so phase-2 workers can
diverge it without ever touching `app/`.

## GOVERNING RULE — donor code, do not invent

> **Leverage existing DONOR code — do not invent.** The donor is the full 3D
> game. Its `data\scripts`, `data\cameras`, `data\shaders`, `.osm` / `.oss` /
> `.aaf`, `light.cfg`, `env.cfg` and `terrainmesh*.osm` are the source of truth
> for this variant. Every 3D decision must cite **donor path:line** or an
> evidence id; translate the donor's algorithms and constants into Godot instead
> of designing new ones. Read the donor read-only (Python bytes + latin-1);
> never run the donor or copy donor binaries. **UNVERIFIED where unreadable —
> no invented values.** (Charter §GOVERNING RULE, owner directive 2026-11-24.)

**Scope: SINGLEPLAYER skirmish only (D-12).** No missions, campaigns, DLC
mission maps, cutscenes or network. Everything outside that is documented as
deferred, not implemented.

## What is duplicated (baseline before any 3D rendering change)

- Real file copies: `scripts/**`, `tests/**`, `tools/**`, `scenes/**`,
  `shaders/**` and every root config/JSON file (`config.json`, `cli.json`,
  `uitest.json`, `selftest.json`, `mechanics.json`, `project.godot`,
  `export_presets.cfg`, …). 4,254 real-copy files / 23,598,642 bytes (~23.6 MB).
- Assets under `assets/**` are **hardlinked** (`os.link`) from `app/assets/**`
  — 3,999 files, 2.312 GiB — so the 3D branch pays no disk duplication cost.
  Godot-managed metadata (`.import`, `.uid`) is copied as **real** files so
  Godot rewrites cannot affect the 2D project.
- `app/.godot/**` and `app/.godot_queue/**` are deliberately **not** copied;
  this project owns and generates its own caches.
- `.gdignore` markers (variant only) hide 2D sprite-bake directories from the
  Godot importer — see below. The hardlinks remain; Godot simply never imports
  those PNGs.

### 2D bake directories excluded from import (variant only)

| Marker (real file, variant only) | Rationale |
|---|---|
| `assets/models/anim/.gdignore` | 1,849 baked sprite sheets + `.import` + 5 metrics JSONs — a 2D render artifact. 3D renders meshes from `models/obj`. |
| `assets/models/sprites/.gdignore` | 358 original-model sprite PNGs (2D bake output). |
| `assets/models/sprites_hi/.gdignore` | 180 high-res sprite PNGs (2D bake output). |

**Kept and imported (needed by 3D):** `assets/models/obj/**` (source geometry,
116 `.obj` + `.mtl`), `assets/models/tex/**` (albedo textures),
`assets/terrain/blocks/**`, `assets/terrain/heightmap/**`, sounds, UI.

**Known 2D dependency (do not break the baseline):** the copied 2D
`world.gd` / `game.gd` / `data.gd` / `main.gd` read metrics from
`assets/models/anim/buildings/buildings.json`, `anim/land_units/index.json`,
`anim/naval_units/index.json`, `anim/land_units/sco_units.json` and
`anim/buildings/mill_rotor.json` via `FileAccess` at runtime. They are inside a
`.gdignore` tree, which only removes them from the import scanner; the physical
files are still readable in a project run, and the baseline selftest is green.
The phase-2 3D world will not use these 2D metrics and will take donor scale
from donor source (with path:line citations) instead.

## Own runner — no contention with 2D

All Godot launches go through `variant3d/tools/godot_runner.py` (never call
`godot` directly). From the repo root:

```bat
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id <name> --timeout 300 -- ^
  --headless --path variant3d -- --self-test variant3d/selftest.json
```

The copied runner keeps `ROOT = Path(__file__).resolve().parents[2]` — which
actually resolves to the **repo root**, the same as the 2D runner — so the only
thing that gives it an independent FIFO is its own spool line:

```python
SPOOL = ROOT / "variant3d" / ".godot_queue"
```

`status` prints the spool path explicitly. The variant queue starts at ticket 0
and is completely independent of `app/.godot_queue/` (which was concurrently
serving wave-5/6 jobs when this branch was created). A first-time checkout must
bootstrap the import cache once (this generates `variant3d/.godot/`):

```bat
python variant3d\tools\godot_runner.py run --id import --timeout 900 -- ^
  --headless --path variant3d --import
```

## project.godot

The renderer is **unchanged**: `gl_compatibility` (Godot 4.4+), which supports
full 3D while keeping the identical 2D picture on every platform. Only the
project identity strings were changed (`config/name` →
`"CossacksGodot - 3D Skirmish Variant"`, plus a matching description). No
display/stretch/environment setting was touched, so 2D behaviour is preserved.

## Phase-2 ownership plan (after this scaffold lands)

Disjoint file owners inside `variant3d/`:

| ID | Owns |
|---|---|
| V7-3 | `main.gd`, `config.gd`, `data.gd` |
| V7-4 | `world3d_full.gd` (full world contract) |
| V7-5 | `camera3d.gd`, `input_controller.gd` |
| V7-6 | `hud.gd` |
| V7-7 | `tests/**` |
| V7-8 | meshes / anim3d (donor `.osm`/`.oss`/`.aaf` → Godot meshes) |
| V7-9 | `scenes/**`, `shaders/**`, environment (`light.cfg`/`env.cfg`) |

Every phase-2 worker: back up touched files, use **only** the variant runner,
run a targeted test, and write one report. Coordinator final gate in
`variant3d/`: selftest 29/29 + uitest 17/17 + clean. 2D gates in `app/` stay
green and are never modified by this branch.

See `docs/coord_swarm_2026-11-24/reports/V70_scaffold.md` for the exact
copy/link counts, path verification, runner proof and baseline selftest result.
