---
title: "ASSET-IMPORT-01 — variant3d mill_rotor.png import-cache regeneration"
area: coord_swarm_2026-11-25
task_id: ASSET-IMPORT-01
job_id: assetimport01-import
ticket: 444
owner: asset-cache repair worker
date: 2026-11-25
status: partial-success-import-clean--target-ctex-still-absent
exit: 0
runner_status: ok
scope: report-only (no game source/asset/config edit)
---

# ASSET-IMPORT-01 — regenerate `variant3d` Godot import cache for `mill_rotor.png`

## Evidence (input facts)

**Owner error evidence (real windowed run), as supplied in the ticket:**

```
ERROR: Unable to open file: res://.godot/imported/mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex.
ERROR: Failed loading resource: res://assets/models/anim/common/buildings/mill_rotor.png.
  at _rotor_material (res://scripts/world3d_entities.gd:1430) -> _attach_rotor (:1458) -> add_building (:1387)
```

**COORD disk facts re-verified before this run (2026-11-25):**

| Item | Measurement |
|---|---|
| Source `variant3d/assets/models/anim/common/buildings/mill_rotor.png` | **PRESENT**, 36,081 B, SHA-256 `E92CAE700C934CA78BFC201BCFE26A83BE5BF32360F0BB557EAEEC8318DC2949` |
| Its `.import` sidecar | **PRESENT**; `importer="texture"`, `uid="uid://y817swuihalq"`, `path="res://.godot/imported/mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex"`, `dest_files=[...same path...]` |
| Target `variant3d/.godot/imported/mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex` | **ABSENT** before and after |
| `variant3d/.godot/imported/` file count | 2,806 before → 2,818 after (+12) |

So the source asset is not missing; this is a generated-cache/.import-scan question, as the ticket stated.

**Documentation read first, as required:**

- `docs/variant3d/README.md` §"Runner and tests (never call `godot` directly)" lines 129–144: first-time bootstrap is
  `python variant3d\tools\godot_runner.py run --id import --timeout 900 -- --headless --path variant3d --import`;
  all invocations stay repo-root relative; `godot` must never be called directly.
- `docs/variant3d/README.md` lines 50–53: `variant3d/.godot/` is generated, not committed; variant has its own serialized runner spool.
- `docs/coord_swarm_2026-11-24/reports/V70_scaffold.md` §1 lines 40–41: source binaries were hardlinked but `.import` (3,383) and `.uid` (468) are **real copies** (Godot may rewrite them).
- §2 lines 86–89 / §3 lines 137–143: the variant runner differs only in `SPOOL = ROOT / "variant3d" / ".godot_queue"`; bootstrap import (`v70-import-bootstrap-r3`) generated the cache in 133.45 s; earlier attempts failed when a concurrent 2D `doctor` killed Godot by name.
- §5 lines 161–171: three real `.gdignore` markers were added, including `variant3d/assets/models/anim/.gdignore` ("1,849 baked sprite sheets + 1,849 `.import` + 5 metrics JSONs + 2 `.TMP`: pure 2D bake output"); `.gdignore` removes files from Godot's import scan, not from disk.
- §6 lines 191–193: `variant3d/.godot/` is generated (not hardlinked), must not be committed, and is to be regenerated with `--import`.

## Runner job

Exact command (run from repo root, via the **variant runner only**):

```bat
python variant3d\tools\godot_runner.py run --id assetimport01-import --timeout 900 --max-wait 1800 -- --headless --path variant3d --import
```

| Field | Value |
|---|---|
| Job / `--id` | `assetimport01-import` |
| Ticket | **444** (allocated at submit; 5 jobs [439–443] were ahead in the FIFO, lock held ~51 s at submit) |
| Result JSON | `variant3d/.godot_queue/results/00000444.json` (verbatim fields below) |
| `status` | `ok` |
| `exit` | `0` |
| `wait` | 284.5281648635864 s (`[runner] ticket 444 ... START (waited 284.53s)`) |
| `run` | 131.10937762260437 s (`[runner] ticket 444 ... END ok (run 131.11s)`) |
| `timeout` | 900.0 s requested; `--max-wait 1800` requested; no timeout/skip occurred |
| `stdout` | `variant3d\.godot_queue\results\00000444_assetimport01-import\stdout.txt` — ends `[DONE] reimport`, `[DONE] loading_editor_layout`; **0** occurrences of `mill_rotor` |
| `stderr` | `variant3d\.godot_queue\results\00000444_assetimport01-import\stderr.txt` — **0 bytes** (empty) |

Result JSON as read from disk:

```json
{
  "ticket": 444,
  "id": "assetimport01-import",
  "argv": ["--headless", "--path", "variant3d", "--import"],
  "created": 1795600057.7360623,
  "wait": 284.5281648635864,
  "run": 131.10937762260437,
  "exit": 0,
  "timeout": 900.0,
  "status": "ok",
  "stdout": "variant3d\\.godot_queue\\results\\00000444_assetimport01-import\\stdout.txt",
  "stderr": "variant3d\\.godot_queue\\results\\00000444_assetimport01-import\\stderr.txt"
}
```

The import did **not** fail; the runner returned cleanly. It did not produce the specific ctex.

## Before / after cache state

| Metric | Before import | After import | Delta |
|---|---:|---:|---:|
| `variant3d/.godot/imported/` file count | 2,806 | 2,818 | +12 |
| `.import` files under `variant3d/assets` | 3,496 | 3,502 | +6 |
| `.import` files whose `dest_files[*.ctex]` is missing | 2,097 | 2,097 | 0 |
| ctex matching `mill_rotor*` or `alg_*` | 0 | 0 | 0 |
| Target `mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex` | absent | **absent** | — |

The +12 files are ctex/md5 pairs for assets outside the ignored tree (e.g. `tile_index_atlas*.png`, `splat_albedo.png`, `alpha.png`, `alphavert.png`). The whole `assets/models/anim/**` tree contributed nothing, so the 2,097 missing-ctex set is unchanged.

## Verification table

| # | Check | Expected | Observed | Result |
|---|---|---|---|---|
| 1 | Source PNG exists | non-zero | 36,081 B, SHA-256 `E92CAE7…C2949` | PASS |
| 2 | `.import` points at target ctex | exact name | `mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex` | PASS |
| 3 | Runner job completed | exit 0 / `ok` | ticket 444, exit 0, `ok`, stderr 0 B | PASS |
| 4 | Target ctex exists after import | non-zero file | **ABSENT** | **FAIL** |
| 5 | Any `mill_rotor*` ctex exists | ≥1 | 0 files | FAIL |
| 6 | Spot-check `alg_cen.png-0e89fb4707113120dd7a603a9ca2b27d.ctex` | present | **ABSENT** | FAIL (same ignored tree) |
| 7 | Spot-check `alg_hou.png-2cc89fb38dc4554215a3014738fcf2fb.ctex` | present | **ABSENT** | FAIL (same ignored tree) |
| 8 | Spot-check newly generated `tile_index_atlas.png-a30951181b3f0a13001b519a289b4874.ctex` | non-zero | 231,730,920 B, SHA-256 `CB26C14B…6B09B` | PASS — proves import actually wrote ctex |
| 9 | Spot-check `splat_albedo.png-3385ada510c1cf3ead2a479c1e787a60.ctex` | non-zero | 902,138 B, SHA-256 `542FAA6C…17217F` | PASS |
| 10 | Spot-check `alpha.png-01c26a6c787a91d524ddd7c6f18ade27.ctex` | non-zero | 51,874 B, SHA-256 `758743A2…272FC1` | PASS |

Full SHA-256 values for the newly generated ctex spot-checks:

- `tile_index_atlas.png-a30951181b3f0a13001b519a289b4874.ctex` — `CB26C14B578599135AF341C52F5A16FE76384CDB1B52D3CED71B6DA3DDB6B09B`
- `splat_albedo.png-3385ada510c1cf3ead2a479c1e787a60.ctex` — `542FAA6CDDE5E1E0D14C123C96C324F6DCACCD52807D62D489C4814AD327217F`
- `alpha.png-01c26a6c787a91d524ddd7c6f18ade27.ctex` — `758743A2937AF2F36A0D15265C63373CA7AB2A32C4F534A7FDE1F6F399272FC1`

## Root-cause note — INFERENCE, not a verified engine log line

`INFERENCE (high confidence)`: a plain `--import` cannot regenerate this ctex because `variant3d/assets/models/anim/.gdignore` recursively excludes the entire `assets/models/anim/**` tree from Godot's import scan, and `mill_rotor.png` lives at `assets/models/anim/common/buildings/mill_rotor.png` — inside that tree. The `.import` sidecar is a leftover **real copy** from `app/` (V70_scaffold.md §1) that still advertises a ctex Godot will never generate while the marker is present.

Supporting observations (vs. the inference): stdout contains 0 `mill_rotor` mentions; 0 ctex was generated for any `alg_*` or `mill_rotor*` asset; the 2,097 missing-ctex count is unchanged; ctex for non-ignored assets *were* generated in the same run. `V70_scaffold.md` §5 states explicitly that `.gdignore` removes files from the import scan, not from disk.

`OBSERVATION`: the `.gdignore` marker and the `.import` sidecar are both still present after the run; neither was touched by this task (both are out of scope).

## Open questions

1. Should the `.gdignore` be narrowed (e.g. move the marker below `common/buildings/`, or add a negating marker) so Godot imports `mill_rotor.png`? That would edit a config/generated-scan boundary and is **out of scope** for ASSET-IMPORT-01; not done.
2. Is the owner's windowed error produced by code that directly loads `res://assets/models/anim/common/buildings/mill_rotor.png` through its stale `.import` (which is why the missing ctex is requested even though the file is in an ignored tree)? The Graceful-fallback ticket handled by another builder is expected to stop the crash; this ticket only covers cache regeneration.
3. Are the other 2,096 missing ctex references (mostly under `.gdignore` trees) benign for runtime, or do any of them have the same load pattern as `mill_rotor.png`? Not audited here beyond the two `alg_*` spot-checks.
4. Two earlier bootstrap attempts were killed by a concurrent 2D `doctor` (`V70_scaffold.md` §3); no such interference was seen in this run, and no `doctor` was run by this worker.
5. The variant `.godot/` cache is generated and uncommitted by design (`V70_scaffold.md` §6); nothing here was staged or committed.

## Summary

The requested bootstrap import was run **only** through the variant runner (`assetimport01-import`, ticket 444) with `--timeout 900 --max-wait 1800`. It completed cleanly (status `ok`, exit 0, 131.11 s after a 284.53 s FIFO wait) and regenerated 12 cache files (2,806 → 2,818), proving the import path works. However, **the target ctex `variant3d/.godot/imported/mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex` is still absent after the run**, along with every ctex under `assets/models/anim/**`. The most likely cause is the intentional `.gdignore` at `variant3d/assets/models/anim/.gdignore` (`V70_scaffold.md` §5), which keeps that tree out of Godot's import scan. No file was fabricated; the runner output is reported verbatim above.

**Scope statement:** No repo source file was edited. No game code, asset, `.import`, config, shader, test, or other report was modified. The `.godot` folder was not deleted wholesale. No `git add`/commit was performed. The only files touched by this task are generated runner/cache artifacts under `variant3d/.godot/` and `variant3d/.godot_queue/` (both gitignored) and this report.
