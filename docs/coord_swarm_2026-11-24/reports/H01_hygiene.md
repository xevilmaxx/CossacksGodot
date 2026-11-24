---
id: H01_hygiene
lane: H1
date: 2026-11-24
topic: hygiene - .gitignore / clean_temp.bat / 3D launchers
status: done
owner_directive: "dont forget especially for 3d to update accordingly clean script .bat and gitignore to avoid porting garbage or useless things around"
secondary_directives:
  - "also point launch3d.bat to correct godot project at this point"
  - "in 3d variant you need models anim pngs? if its 3d why even need baking"
godot_runs: 0
files_owned: 5
---

# H1 — 3D hygiene (gitignore, cleanup, launchers)

## Summary

Kept all 2D rules intact; added opt-in cleanup and ignores for the separate
`variant3d/` Godot project and for 3D-conversion garbage in **both** projects.
Repointed the `launch_3d.bat` muscle-memory entry at the **active** 3D project
using **Option A**: a compatibility shim delegating to a new canonical
`launch_variant3d.bat`, which launches `variant3d/` through **its own**
serialized runner. The old M0 terrain-only sandbox is documented as legacy,
not launched. No Godot was run; no git tracking/asset deletion was performed.

## Verification performed (read-only)

- `python` assertion script (temp, outside repo): all referenced paths exist
  (`variant3d/project.godot`, `variant3d/tools/godot_runner.py`,
  `launch_variant3d.bat`, all 3 backups); all expected rule strings present;
  2D rules retained; line-ending counts compared to backups.
- `git check-ignore -v`: artifacts ignored, source assets **not** ignored:
  - ignored: `variant3d/.godot/*`, `variant3d/.godot_queue/status.json`,
    `variant3d/shots/foo.png`, `*.blend1`, `*.glb.tmp`, `*.glb.part`,
    `*.gltf.tmp`, `variant3d/assets/models/anim/**/*.png`,
    `variant3d/assets/models/sprites*/**/*.png`, `app/assets/models/obj/*.obj`
    (pre-existing 2D rule).
  - **not** ignored: `app/assets/models/glb/mesh.glb`,
    `variant3d/assets/models/glb/mesh.glb`,
    `variant3d/assets/models/obj/peasant.obj` (new negation),
    `app/shots/portvis-final.png` (curated 2D exception).
- `git diff --numstat -- .gitignore clean_temp.bat launch_3d.bat`:
  `.gitignore +49/-1`, `clean_temp.bat +46/-10`, `launch_3d.bat +20/-28`;
  `launch_variant3d.bat` untracked (new).
- `Test-Path app\shots\t6t90_dumps\dump_20261113_a.json` = **True**;
  `app\shots\final_fullmap_dump.json` = **False** (confirmed stale default).

## Per-file changes

### 1. `.gitignore` — lines 84–130 (new block appended after `rustport/target/`)

| Lines | Change |
|---|---|
| 84–94 | `variant3d/.godot/`, `variant3d/.import/`, `variant3d/.godot_queue/`, `variant3d/shots/**` (directory itself deliberately NOT excluded so a curated `!` exception can be added later), plus `variant3d/**/*_dump*.json`, `temp_*.json`, `*_tmp.json`. |
| 96–103 | 3D-conversion garbage in **both** projects, via global patterns: `*.blend1`, `*.blend2`, `*.glb.tmp`, `*.glb.part`, `*.tmp.glb`, `*.gltf.tmp`. |
| 105–107 | **Deliberately no rule for `app/assets/models/glb/**`.** V7-2 (`reports/V72_mesh_conversion_feasibility.md:233-260,295-299,344`) plans to **commit** converted `.glb` meshes; Godot imports them as `PackedScene`, so they are real 3D source assets, not build artifacts. Only transient exports are ignored. |
| 109–119 | Comment: the 3D variant does **not** use 2D bake outputs (sprite sheets/atlases). Ignores `variant3d/assets/models/anim/**/*.png`, `sprites/**/*.png`, `sprites_hi/**/*.png` and their `.png.import` sidecars so nobody re-adds baked sheets as "3D assets". These are hardlinked leftovers — `clean_temp` must never delete them. `models/obj`, `models/glb`, `models/tex` remain trackable. |
| 121–124 | Targeted negation `!variant3d/assets/models/obj/` + `!variant3d/assets/models/obj/**`. The legacy `obj/` rule at line 19 (C# build output) also matched real 3D meshes; only variant3d geometry is re-included. The 2D rule is otherwise unchanged (`app/assets/models/obj/*.obj` stays ignored). |
| 126–130 | Donor note retained/expanded: `C:\Games\Cossacks 3` is private-use and donor meshes/textures/binaries must **never** be committed. No broad `variant3d/assets` ignore added — tracked source and `.import` sidecars must stay visible. |

All pre-existing 2D rules (lines 1–82, including the 4 curated `app/shots` PNG
exceptions, `app/.godot/`, `app/.godot_queue/`, `rustport/target/`) untouched.

### 2. `clean_temp.bat` — lines 1–182

| Lines | Change |
|---|---|
| 8 | Header states scope: `app\` (2D) and, with `/VARIANT3D`, `variant3d\` (active 3D). |
| 11–18 | **Existing safety guard kept verbatim**: abort if any `godot.exe` is running. |
| 20–29 | New `V3D=0` state and `/VARIANT3D` flag parsed alongside `/FULL`, `/SHOTS`, `/Y`. |
| 32–45 | Menu option `[4] Standard + variant3d runner queue, caches, generated shots`; `choice /C 1234AN`; errorlevel mapping shifted (6=cancel, 5=all, 4=v3d). |
| 47–63 | `/A` (ALL) now also sets `V3D=1`; new `:v3d` branch. `/FULL` and `/SHOTS` unchanged. |
| 69–87 | "Will clean" listing gains 3 variant3d lines; PROTECTED list gains `variant3d\scripts, assets, tools, tests, scenes, shaders`, hardlinked/donor-derived files, "3D uses real meshes, not 2D bake sheets; sprite atlases stay untouched", and a note that runner locks are left to `godot_runner.py doctor / reset`. |
| 95–149 | Existing 6 steps renumbered `/5` and `/6` → consistent `/8`; **no deletion logic changed**. |
| 151–159 | New `[7/8]`: removes/recreates `variant3d\.godot_queue\results` and deletes `variant3d\.godot_queue\*.json`. `jobs/` and `godot.lock` are deliberately left to the runner. |
| 161–168 | New `[8/8]`: removes `variant3d\.godot\` and `.import\` caches, generated `variant3d\shots\*` PNG/JSON/MP4/log, and cache extensions `*.blend1 *.blend2 *.glb.tmp *.glb.part *.tmp.glb *.gltf.tmp`. **Never touches `variant3d\assets` or 2D bake sheets.** |

Both new steps are gated by `if "%V3D%"=="1"` (or `/A`) and echo "skipped"
otherwise, so default behaviour is unchanged.

### 3. `launch_3d.bat` — lines 1–27 (rewritten, Option A)

- Lines 2–5: states the active project is `variant3d/` (wave-7 full variant) and
  that this file delegates to `launch_variant3d.bat` / variant3d's own runner.
- Lines 7–11: documents the **legacy M0 terrain-only sandbox** (visual FAIL):
  `"%GODOT%" --path app res://scenes/terrain3d_sandbox.tscn -- --stay`; notes the
  old default `app\shots\final_fullmap_dump.json` no longer exists, that a
  surviving dump is `app\shots\t6t90_dumps\dump_20261113_a.json` (verified), and
  that no dump is assumed. Active 3D = `variant3d/` + wave-6 heightmap.
- Lines 15–24: explicit clear errors if `variant3d\project.godot` or
  `launch_variant3d.bat` is missing.
- Lines 26–27: `call ... %*` + `exit /b %errorlevel%`.
- **Exact launch target after delegation:**
  `python variant3d\tools\godot_runner.py run --id launch3d-manual --timeout 900 -- --path variant3d --stay [user args]`
- Rationale: preserves the familiar `launch_3d.bat` entry point while making it
  impossible to accidentally launch the failed legacy sandbox; no new
  `launch_legacy_3d_sandbox.bat` was created (documented in comments instead,
  per "fewer files" allowance). No Godot invocation was executed by this agent.

### 4. `launch_variant3d.bat` — lines 1–67 (new file)

- Lines 2–8: canonical launcher for the active 3D project; preferred path is
  variant3d's own FIFO runner (no contention with `app/` 2D jobs).
- Lines 12–16: aborts with a clear message if `variant3d\project.godot` missing.
- Lines 18–21: uses the runner when `variant3d\tools\godot_runner.py` exists.
- Lines 23–35: runner path — `python variant3d\tools\godot_runner.py run --id
  launch3d-manual --timeout 900 -- --path variant3d --stay %*`; requires
  `python` + `godot` on PATH; surfaces runner errors. Verified the runner's CLI
  (`godot_runner.py:571-575`) accepts `--id`, `--timeout` and remainder args.
- Lines 37–41: three `[WARNING]` lines before any direct launch.
- Lines 43–67: labelled direct-windowed fallback with the same Godot discovery
  convention as the old `launch_3d.bat` (PATH → WinGet link → Program Files),
  and an install hint if Godot is absent.
- `variant3d/project.godot:8` main scene is `res://scenes/main.tscn` (exists),
  so no scene argument is hard-coded.

### 5. Backups

| Original | Backup |
|---|---|
| `clean_temp.bat` | `inbox/backup/clean_temp.bat.bak-H1` |
| `.gitignore` | `inbox/backup/.gitignore.bak-H1` |
| `launch_3d.bat` | `inbox/backup/launch_3d.bat.bak-H1` |
| `launch_variant3d.bat` | N/A — new file, no prior content |
| this report | N/A — new file |

All three backups verified present via `python` path check.

## Deliberately NOT done

- **No git state changes**: nothing staged/committed, no `git add -f`, no
  tracking edits. The 531 MB of tracked `app/shots/**` diagnostics and the
  untracked `app/scripts/heightmap*.gd` were left exactly as found.
- **No file deletion**: no cleanup script was executed; no tracked, hardlinked,
  donor or asset file was removed. `variant3d/assets/**` is explicitly protected.
- **No Godot runs** and no runner jobs submitted (per lane scope).
- **No 2D rule removals** and no changes to 2D cleanup behaviour or curated
  `app/shots` exceptions.
- **No ignore rule for `app/assets/models/glb/**`** (V7-2 plans to commit those
  meshes) and **no broad `variant3d/assets` ignore** (would hide real 3D source).
- **No new legacy launcher file**; the legacy command lives in a comment.
- No edits to `app/`, `variant3d/` source, or other docs.

## Open questions

1. Should `variant3d/shots/` ever hold curated README images? Currently ignored
   wholesale; if so, a coordinator must add explicit `!` exceptions (the parent
   directory is intentionally not excluded so this is possible).
2. Should V7-2's converted `.glb` land in `app/assets/models/glb` (shared with
   2D) or only in `variant3d/assets/models/glb`? This lane assumes both paths
   stay trackable and adds no ignore either way.
3. The targeted `!variant3d/assets/models/obj/**` negation makes those hardlinked
   meshes visible to git. If the coordinator prefers `variant3d/assets` to stay
   entirely untracked, replace it with a directory-level rule — do not delete
   the files.
4. `--stay` is forwarded to `variant3d` main scene; if it is not honoured there,
   the runner job simply stays alive until `--timeout 900` (or the window is
   closed). Confirm with V7-3/V7-9 when the main scene contract is final.
