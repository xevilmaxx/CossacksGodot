---
agent: V7-0
role: micro-builder / scaffold (Wave 7 phase 1)
date: 2026-11-24
session: ses_df2e3adb8ffeql0mmxDCG5BTBv
branch: variant3d (full Godot 3D skirmish variant)
status: DONE
gate: baseline selftest 29/29 PASS (identical to 2D), exit 0
owns: "variant3d/** (new) + this report only; app/ untouched"
---

# V7-0 — `variant3d/` scaffold, own runner, baseline proof

## 0. Governing rule recorded (owner directive, 2026-11-24)

The branch's 3D work must **translate existing donor code, never invent**:
donor `data\scripts`, `data\cameras`, `data\shaders`, `.osm` / `.oss` / `.aaf`,
`light.cfg`, `env.cfg`, `terrainmesh*.osm` are the source of truth. Every 3D
decision needs a **donor path:line citation or evidence id**; read donor read-only
(Python bytes + latin-1), never run it or copy donor binaries; values that cannot
be read stay **UNVERIFIED — no invented constants**. Scope is
**SINGLEPLAYER skirmish only (D-12)**: no campaign, missions, DLC mission maps,
cutscenes or network. This is restated in `variant3d/README.md`. The scaffold
itself is purely mechanical (no 3D code written), so it complies by construction.

## 1. Copy / link ledger (exact counts from the scaffold pass)

Scaffold script: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v70_scaffold.py`
(outside the repo, as required). Machine-readable detail:
`...\Temp\opencode\v70_scaffold_summary.json`.

| Source | Action | Files | Bytes |
|---|---|---:|---:|
| `app/scripts/**` | real copy | 41 | 947,746 |
| `app/tests/**` | real copy | 111 | 1,860,477 |
| `app/tools/**` | real copy | 230 | 17,566,938 |
| `app/scenes/**` | real copy | 2 | 357 |
| `app/shaders/**` | real copy | 2 | 15,798 |
| `app/` root files (17 JSON/config/doc files incl. `project.godot`, `export_presets.cfg`) | real copy | 17 | 146,466 |
| `app/assets/**` non-import binaries (PNG/OGG/OBJ/MTL/DDS/BMP/JSON/…) | **`os.link` hardlink** | 3,999 | **2,482,248,044** |
| `app/assets/**` `.import` (3,383) + `.uid` (468) | real copy (Godot may rewrite) | 3,851 | 3,060,860 |
| **Scaffold totals** | | **8,253** | **2,505,846,686** |

- **Real-copy subtotal:** 4,254 files / 23,598,642 bytes.
- **Hardlinked subtotal: 3,999 files / 2,482,248,044 bytes = 2.312 GiB saved**
  (no second copy of the 2.31 GiB asset tree). `app/assets/**` itself is 7,850
  files / 2,485,308,904 bytes.
- **Hardlink fallbacks: 0** (every `os.link` succeeded; same volume).
- Skipped entirely: `app/.godot/**` (9,719 files / 1.815 GiB), `app/.godot_queue/**`,
  plus transient `app/scans/**` and `app/shots/**`.
- After the pass, 3 new real `.gdignore` files were added (below) → 8,256 files.
  Godot's own import later generated `.gd.uid` sidecars under `scripts/` and
  `tests/` (2 + 18) and one new `.import` for a previously unimported terrain
  PNG; those are generated artifacts, not scaffold copies.

**Inode proof** (`os.path.samestat`, source vs variant):
`assets/sounds/alg.ogg` → `same_inode=True`;
`assets/models/anim/alg/buildings/alg_cen.png` → `same_inode=True`;
`assets/sounds/alg.ogg.import` → `same_inode=False` (real copy);
`assets/terrain/decals/eurgold.dds.uid` → `same_inode=False` (real copy).
`.uid` was copied real as a defensive measure even though the charter only
required `.import` — both are Godot-managed metadata.

## 2. Path verification — the runner's own FIFO

The task brief expected `parents[2]` to resolve to `variant3d`; measured reality:

```
variant3d/tools/godot_runner.py
  parents[0] = <root>/variant3d/tools
  parents[1] = <root>/variant3d
  parents[2] = <root>            <-- repo root, NOT variant3d
```

So `ROOT` is the **repo root** for both runners — identical to the 2D runner.
That matters: the invocation must stay repo-root-relative (`--path variant3d`,
`--self-test variant3d/selftest.json`), which the given baseline command already
is. `_candidate_paths()` in `main.gd` resolves such a path against
`res://`'s parent (= workspace root), so the report is written into
`variant3d/selftest.json` as intended. **No path syntax change was needed.**

What makes the runner independent is its spool line, changed in the **variant
copy only**:

```python
# app/tools/godot_runner.py
SPOOL = ROOT / "app" / ".godot_queue"
# variant3d/tools/godot_runner.py
SPOOL = ROOT / "variant3d" / ".godot_queue"
```

A single diagnostic line was added to `cmd_status()` so the spool is provable:
`print(f"spool        = {SPOOL}")`. All other runner logic is byte-identical.

`python variant3d\tools\godot_runner.py status` from the repo root printed:

```
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 0
next_ticket = 0
pending      = 0 []
godot.lock   = free
```

It created `variant3d/.godot_queue/{jobs,results}` on first status. At the same
moment the 2D runner reported `now_serving = 1310`, `next_ticket = 1314`,
4 pending jobs and `godot.lock = HELD` — proving the queues are disjoint and the
variant introduces zero contention with the wave-5/6 swarm.

## 3. Baseline selftest (the mechanic-duplication gate)

Command exactly as specified, from the repo root, through the variant runner:

```
python variant3d\tools\godot_runner.py run --id v70-baseline-selftest-r3 --timeout 300 -- \
  --headless --path variant3d -- --self-test variant3d/selftest.json
```

**Result: `exit 0`, `status ok`, run 82.13 s, 0 s wait, ticket 5,
job id `v70-baseline-selftest-r3`.** Regenerated
`variant3d/selftest.json` (mtime 11:50:20) reports `passed: true`,
**29/29 steps passed**. stdout ends with
`self-test report: .../variant3d/selftest.json`.

Equality check against the copied 2D baseline (`app/selftest.json`):

- 29/29 step **name + detail + passed** strings identical (zero diffs).
- `resources_gathered` identical (food 45, gold 245.023999999998, stone 120,
  trade 65, wood 712); `shots_fired` 73 identical.
- Only non-semantic difference: `sim_seconds` 366.875 vs 366.78125 (frame-timing
  jitter); per-step `wall_ms` also varies, as expected.

### Bootstrap history (first attempts failed — diagnosed, not a mechanic regression)

| Ticket | Job id | Result | Cause / fix |
|---:|---|---|---|
| 0 | `v70-baseline-selftest` | failed, 139.38 s | Fresh project had no `.godot/global_script_class_cache.cfg` → `Could not find type "C3Game"` for every `class_name`. The charter said caches are generated, not copied. |
| 1, 3 | `v70-import-bootstrap`, `-r2` | failed, 72 s / 77 s | Import progressed (86 → 283 `.ctex`) then died with exit 1, empty stderr — consistent with an external `taskkill` from a concurrently running 2D `doctor`. Re-run only when 2D queue was idle. |
| 4 | `v70-import-bootstrap-r3` | **ok**, 133.45 s | Generated `variant3d/.godot/` (3,029 files / 1,276,451,922 bytes; 847 `.ctex` vs app's 4,195 thanks to `.gdignore`). |
| 5 | `v70-baseline-selftest-r3` | **ok**, 82.13 s | 29/29 PASS, identical to 2D. |

Bootstrap command for future checkouts (via the variant runner only):
`... run --id import --timeout 900 -- --headless --path variant3d --import`.

## 4. `project.godot` settings — 3D-capable, 2D unaffected

Read before editing: `renderer/rendering_method="gl_compatibility"` and
`renderer/rendering_method.mobile="gl_compatibility"` under `[rendering]`, with
`config/features=PackedStringArray("4.4", "GL Compatibility")`. Godot 4.4+
Compatibility renderer supports full 3D, so **all rendering/features/display/
stretch/environment settings were kept byte-for-byte**. Only two identity
strings changed (variant file only):

- `config/name`: `"CossacksGodot - Singleplayer Port"` → `"CossacksGodot - 3D Skirmish Variant"`.
- `config/description`: appended "3D variant (singleplayer skirmish only). Donor-driven;".

## 5. `.gdignore` exclusions — 2D bake dirs (variant only)

New real (0-byte) files, absent from `app/`:

| Exact marker path | Rationale |
|---|---|
| `variant3d/assets/models/anim/.gdignore` | 1,849 baked sprite sheets + 1,849 `.import` + 5 metrics JSONs + 2 `.TMP`: pure 2D bake output. 3D renders meshes; no baking needed. |
| `variant3d/assets/models/sprites/.gdignore` | 358 original-model sprite PNGs (2D bake output). |
| `variant3d/assets/models/sprites_hi/.gdignore` | 180 high-res sprite PNGs (2D bake output). |

**Explicitly NOT ignored (required by 3D):** `assets/models/obj/**` (348 files,
116 `.obj` source geometry + `.mtl` + `.import`), `assets/models/tex/**` (233
files, albedo textures), `assets/terrain/blocks/**`, `assets/terrain/heightmap/**`,
`assets/sounds/**`, `assets/ui/**`. No other pure sprite-atlas dir exists under
`assets/models` (only `anim`, `sprites`, `sprites_hi`, `obj`, `tex`).

**Dependency documented, not broken:** the copied 2D `world.gd`, `game.gd`,
`data.gd` and `main.gd` read
`assets/models/anim/buildings/buildings.json`,
`assets/models/anim/land_units/index.json`,
`assets/models/anim/naval_units/index.json`,
`assets/models/anim/land_units/sco_units.json`,
`assets/models/anim/buildings/mill_rotor.json` via `FileAccess` at runtime.
`.gdignore` removes them from Godot's import scan, not from the on-disk filesystem;
the 29/29 baseline above proves they still resolve in a project run. Phase-2 3D
world code will not use them and will derive scale from donor source with
path:line citations. **Exported builds would need these JSONs shipped explicitly.**

## 6. Open questions / handoff notes

1. **Concurrent `doctor` hazard** — an external `taskkill` pattern killed two
   import attempts. Phase-2 workers share only the variant FIFO; they must not
   run `doctor` while a variant import is active, and 2D `doctor` kills Godot by
   name regardless of spool.
2. **Import cache cost** — `variant3d/.godot/` is 1.19 GiB. It is generated
   (not hardlinked) and is smaller than 2D's 1.815 GiB because of `.gdignore`.
   Do not commit it; regenerate with `--import`.
3. **In-flight 2D edits snapshotted** — `app/scripts/main.gd` had uncommitted
   additive test hooks (`--check-self-base`, `_json_diff`) and a new
   `app/scripts/heightmap_world3d.gd` when the copy ran. Both were copied
   verbatim; the baseline is green, so they are benign.
4. **Godot 4.7.2 sidecars** — import generated `.gd.uid` files for scripts/tests.
   Harmless; phase-2 should leave them with the copied scripts.
5. **Export path** — `.gdignore` JSON-metric dependency (§5) needs an explicit
   include list if a 3D export preset is ever built.
6. `launch_variant3d.bat` appeared at the repo root during this work — it is
   **not** mine (my scope is `variant3d/**` + this report) and was left untouched.
7. Next gates: phase-2 owners start now; coordinator final gate in `variant3d/`:
   selftest 29/29 + uitest 17/17 + clean. All 2D gates stay in `app/`.

## 7. Scope compliance

Only `variant3d/**` (all new files) and this report were created/modified.
Nothing under `app/` or existing docs was changed. No Godot process was launched
directly — every launch went through `variant3d/tools/godot_runner.py`.
