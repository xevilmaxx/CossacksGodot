---
id: STAGE-IMPORT-01
owner: STAGE-IMPORT-01 (asset-import worker subagent)
role: "Run exactly one Godot import job through the variant runner so the 108 stage/scaffold OBJs from BUILD-ART-BATCH-01 get .import sidecars and import resources"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: IMPORT_SIDECARS_PRESENT__108_OF_108__RUNTIME_LOAD_STILL_UNVERIFIED__NO_PARITY_CLAIM
scope: "Only Godot-generated .import sidecars under variant3d/assets/models/obj/** and variant3d/assets/models/tex/scaffold.png.import, Godot-generated variant3d/.godot/imported/** resources, and this report. No source OBJ/MTL/PNG, manifest, game code, test, config or app/** file was edited by hand."
owns:
  - variant3d/assets/models/obj/*.obj.import  (Godot-generated only)
  - variant3d/assets/models/tex/scaffold.png.import  (Godot-generated only)
  - variant3d/.godot/imported/**  (Godot-generated only)
  - docs/coord_swarm_2026-11-25/reports/STAGE_IMPORT_01.md
labels: [observed, derived, UNVERIFIED, NO_VISUAL_PARITY]
parity: "NO PARITY CLAIM — no mesh was rendered or A/B captured; only import metadata was produced"
---

# STAGE-IMPORT-01 — Godot import sidecars for the 108 stage/scaffold OBJs

> [!IMPORTANT]
> This ticket closes only the **import-metadata** gap left by
> `BUILD_ART_BATCH_01.md` §7 ("the 108 new OBJs have no `.obj.import`
> sidecars because no Godot import was performed") and re-checked by
> `QA_BUILD_ART_01.md` row 2b / §3 (`load()`-as-`Mesh` then UNVERIFIED).
> **One** import job was run through the variant runner. It generated the
> sidecars and import resources. It did **not** run the game, load a mesh at
> runtime, or capture any image. **No visual, animation or donor parity is claimed.**

## 1. Sources read (read-only)

| Input | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/BUILD_ART_BATCH_01.md` (206 lines) | Evidence for the 108 new OBJs/MTNs + `scaffold.png`, manifest 280, and the explicit "no Godot import" gap (§7, §11, §12). |
| `docs/coord_swarm_2026-11-25/reports/QA_BUILD_ART_01.md` (248 lines) | Stable on-disk 280/280/174 counts; runtime-load gate UNVERIFIED (§3 row 2b). |
| `docs/variant3d/README.md` lines 139-144 | Import bootstrap: `python variant3d\tools\godot_runner.py run --id import --timeout 900 -- --headless --path variant3d --import`; line 129 "never call `godot` directly". |
| `variant3d/tools/godot_runner.py` | Read-only inspection of `cmd_run` / `wait_for_turn` / `--max-wait` semantics; no edit. |
| `python variant3d\tools\godot_runner.py status` | Pre-job queue state: spool `variant3d\.godot_queue`, `now_serving=528`, `next_ticket=533`, pending `[528..532]`, `godot.lock` HELD (age 27.7 s), completed 500. Queue waits treated as normal. |

## 2. Exact command and job result

Run once from the repository root with `python` (3.14), through the **variant runner only**:

```
python variant3d\tools\godot_runner.py run --id stageimport01-import --timeout 900 --max-wait 1800 -- --headless --path variant3d --import
```

`--max-wait 1800` was passed as specified; the job was submitted **once** and
never re-submitted. The queue was never mutated: no `cancel`, `doctor`,
`ack`, `reset`, `unwedge` or direct `godot` invocation was used. A concurrent
swarm job (`nationspawn01-smoke`, ticket 533) entered the queue immediately
before this one; it was left untouched.

| Field | Value |
|---|---|
| Job id | `stageimport01-import` |
| Ticket | **534** (job file `variant3d\.godot_queue\jobs\00000534.json`) |
| Submitted (local) | 2026-11-25 12:16:16.654417 |
| Godot run started | 2026-11-25 12:22:22.753458 (**queue wait 366.10 s**) |
| Godot run ended | 2026-11-25 12:25:02.302932 (**run 159.55 s**) |
| Job `--timeout` | 900 s (not reached) |
| `exit` | **0** |
| `status` | **ok** |
| `stderr.txt` | **0 bytes** |
| `stdout.txt` | 41,358 bytes |
| Godot version | `Godot Engine v4.7.2.stable.official.ed1daf0bf` |

Result JSON `variant3d\.godot_queue\results\00000534.json` (verbatim fields):
`"ticket": 534`, `"id": "stageimport01-import"`,
`"argv": ["--headless","--path","variant3d","--import"]`,
`"wait": 366.0990414619446`, `"run": 159.54947328567505`,
`"exit": 0`, `"status": "ok"`.

Runner console output (verbatim):
```
[runner] ticket 534 'stageimport01-import' START (waited 366.10s)
[runner] ticket 534 'stageimport01-import' END ok (run 159.55s)
```

stdout evidence: `_update_scan_actions` lists all 108 stage names
(`aca1.obj` … `towa.obj`) plus `scaffold.png`; `reimport` then reports
**109 steps** and executes pre-reimport operations for exactly
`scaffold.png` + the 108 stage OBJs, ending `[ DONE ] reimport`.
No `SCRIPT ERROR` / error line appears; stderr is empty.

## 3. Before → after sidecar counts (**observed**)

All counts are recursive filesystem reads of the two asset trees, taken with
the same script before and after the job.

| Item | Before | After | Delta |
|---|---:|---:|---:|
| `.obj` in `variant3d/assets/models/obj/` | 280 | 280 | 0 |
| `.mtl` in `variant3d/assets/models/obj/` | 280 | 280 | 0 |
| `.png` in `variant3d/assets/models/tex/` | 174 | 174 | 0 |
| `.obj.import` in `obj/` | **172** | **280** | **+108** |
| stage (108) `.obj.import` present | **0 / 108** | **108 / 108** | +108 |
| `scaffold.png.import` | absent | **present, 946 B** | +1 |
| `.png.import` in `tex/` | 173 | **174** | +1 |
| total `.import` under `assets/models` | 345 | **454** | +109 |
| `.uid` files under `assets/models/obj` or `tex` | 0 | **0** | 0 |
| `.godot/imported/` files | 2,820 | **3,038** | +218 |
| `.godot/imported/*.ctex` | 910 | **911** | +1 |
| `.godot/imported/*.obj-*.mesh` | 172 | **280** | +108 |
| `.godot/imported/*.obj-*.md5` | 172 | **280** | +108 |
| stage-named files in `.godot/imported/` | 0 | **216** (108 `.mesh` + 108 `.md5`) | +216 |
| scaffold-named files in `.godot/imported/` | 0 | **2** (`.ctex` + `.md5`) | +2 |

**`.uid` observation (derived):** this Godot 4.7.2 import created **no separate
`.uid` sidecar files** anywhere under `assets/models/obj` or `assets/models/tex`.
The unique resource id is embedded as `uid="uid://…"` inside each `.import`
file. This matches the task's "`.uid` if created by Godot" condition — none
were created, so none are claimed.

## 4. Sample paths and sidecar validity (**observed**)

Sample stage sidecar `variant3d/assets/models/obj/aca1.obj.import` (697 B):
```
path="res://.godot/imported/aca1.obj-b301662d0c65cccbc5afa33f10ee4896.mesh"
uid="uid://dduvowvonxya4"
```

Sample stage sidecar `variant3d/assets/models/obj/aca1a.obj.import` (702 B):
```
path="res://.godot/imported/aca1a.obj-561deda87868c5c63d75a824c4309487.mesh"
uid="uid://c7nalcv0sswbn"
```

Scaffold sidecar `variant3d/assets/models/tex/scaffold.png.import` (946 B):
```
path="res://.godot/imported/scaffold.png-8e9d0f48448113b1eaeb490282f225cc.ctex"
uid="uid://dceeyghdot21f"
```

Other sample generated resources (in `variant3d/.godot/imported/`):
`aca2.obj-6212ca3279a070287af69e1e0277b3e1.mesh`,
`aca2a.obj-a1ee7a606759b8a50bad11fb64d214b7.md5`,
`scaffold.png-8e9d0f48448113b1eaeb490282f225cc.md5`.

## 5. Verification (**observed**, read-only re-read after the job)

| Gate | Result | Basis |
|---|---|---|
| Ticket 534 exists with id/argv/timeout as specified | **PASS** | `jobs/00000534.json` |
| Runner status `ok`, `exit` 0 | **PASS** | `results/00000534.json`; console START/END lines |
| stderr empty | **PASS** | `stderr.txt` = 0 bytes |
| All 108 stage OBJs now have `.obj.import` | **PASS** | 108 / 108, 0 missing |
| All 108 sidecars have **non-empty** `path` and `uid` | **PASS** | parsed `path=`/`uid=` for all 108; 108 unique uids, 0 empty |
| Every sidecar `path` resolves to an existing non-zero resource | **PASS** | 108 / 108 target `.mesh` files exist under `.godot/imported/` |
| Sidecar sizes (108) | **observed** | min **695 B**, max **702 B**, total **75,476 B** |
| `scaffold.png.import` present, non-empty path/uid | **PASS** | 946 B; target `.ctex` exists |
| New `.mesh` resources appear | **PASS** | +108 `.obj-*.mesh`, 280 total; sizes min **1,655 B**, max **949,837 B**, total **24,886,018 B** |
| New `.ctex` appears | **PASS** | +1 (`scaffold.png-8e9d0f48448113b1eaeb490282f225cc.ctex`), 911 total |
| 280 OBJ / 280 MTL / 174 PNG source counts unchanged | **PASS** | identical before/after census |
| `scaffold.png` bytes unchanged | **PASS** | SHA-256 `d7c259ae35f13f6662cec9c70f3ae292e4786a6187926360cdca63524e8b1007` — byte-identical to `BUILD_ART_BATCH_01.md` §4 |
| No tracked OBJ/MTL/PNG modified | **PASS** | `git status --short` on `obj/`+`tex/`: 0 modified tracked files; only 108 new `.import` + 1 new `.import` are untracked |
| No source file touched during the import window | **PASS** (derived from mtimes) | 108 stage OBJ mtimes 12:07:39–12:09:56 and `scaffold.png` mtime 12:09:57 all precede the Godot run 12:22:22–12:25:02; sidecar mtimes (e.g. `aca1.obj.import` 12:24:29, `scaffold.png.import` 12:23:40) fall inside it |
| No `.uid` files created | **observed** | 0 in both trees (uid embedded in `.import`) |

**Scope guard:** at verification time (before 12:28 local), `git status --short`
limited to `variant3d/assets/models/obj` and `tex` showed exactly **108** new
`.obj.import` + **1** new `scaffold.png.import` and **0** other changes; a
scoped check of `variant3d/scripts`, `variant3d/tools` and `app` returned
**0** entries. **Post-verification observation:** a concurrent swarm commit
`52a81f97` (`step`, 2026-11-25 12:28:06 +0100) subsequently tracked those
sidecars, so a *current* `git status` no longer lists them; re-check confirmed
all **280** `.obj.import` files and `scaffold.png.import` are still present on
disk. This was a foreign commit, **not** a git operation by this ticket.
No source asset, manifest, converter, runtime script, test, config or `app/**`
file was edited by hand by this ticket. No git add/commit/checkout/stage was
performed. The temporary census/verification scripts and logs live in the OS
temp folder (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`), not in
the repo.

**Not done (explicitly out of scope, therefore UNVERIFIED):** Godot
`ResourceLoader.exists()` / `load()`-as-`Mesh` from a running script for the
108 paths; visual A/B capture; donor parity; integration of the new meshes
into stage construction. A `.import` sidecar plus a generated `.mesh` is
**import metadata**, not proof of a successful runtime `load()` or of correct
visual output.

## 6. Remaining runtime integration ticket

The original ordered plan `a → b → c → d` is unchanged; this ticket only
supplies import metadata for step (b).

1. **BUILD-ART-C — runtime integration** (still outstanding): in
   `variant3d/scripts/world3d_entities.gd`, restricted to the
   `BUILD_STAGES_01` block, resolve the 108 new OBJ names, read per-stage
   bbox from `_bbox[sid+suffix]` with base fallback, make the scaffold child
   visible with `<sid><suffix>a` art and `<sid>a` at completion, stop the
   unconditional "no stage OBJ" telemetry, decide `gat` wall-rule handling
   in `_build_stage_suffix()`, and re-apply/assert player tint after a mesh
   swap. Frozen blocks and public signatures stay unchanged.
2. **BUILD-ART-D — isolated 64² atom** (still outstanding): new
   `variant3d/tests/t_build_stages.gd` + result JSON asserting suffixes
   1/2/3/4, stage source strings, visible stage scaffold, per-stage bbox and
   stage/scaffold hit counters; runner status ok, exit 0, stderr 0 bytes,
   `SCRIPT ERROR == 0`; atom-only, never merged with the integrated
   `selftest.json`.
3. **Runtime-load verification** (carried forward from `QA_BUILD_ART_01.md`
   row 2b): still needs a script-level `ResourceLoader.exists()` +
   `load()`-as-`Mesh` check; sidecars alone do not close that gate.
4. **Visual A/B capture** — required before any donor-parity statement.

## 7. No-parity claim

**No visual, animation or donor parity is claimed.** Only Godot import
metadata and cached import resources were generated. No donor `.osm`/`.oss`
was read or copied by this ticket, no mesh was rendered, no game was launched
and no A/B capture exists. The imported meshes remain static bind-pose PORT
APPROXIMATIONS under the governing charter rule. Labels stay `UNVERIFIED` /
`NO_VISUAL_PARITY` until a runtime atom and an A/B capture exist.

## 8. Open questions

Carried forward, with one new:

1. **Q1** — Completion scaffold (`<sid>a`) visible per `ontagstates.inc:112-127`,
   or hidden/freed with a PORT APPROXIMATION label? Owner decision, ticket C.
2. **Q2** — Authoritative `wal`/`gat` stage actor remains UNVERIFIED.
3. **Q3** — Are the 10 minimal 8-vert donor meshes intentional LOD or
   placeholders? Render test still needed (import metadata cannot answer).
4. **Q4** — Should `gat` fold to stages 1..2 like `wal` in
   `_build_stage_suffix()`?
5. **Q5** — Re-apply player tint after a stage mesh swap, or assert identical
   surface counts? Ticket C.
6. **Q6** — Use the imported MTL from `scaffold.png` or an explicit port
   material? Donor shader/blend is engine-side and UNVERIFIED.
7. **Q7** — Death stages (`_death1`/`_death2`, `debris.dds`) remain deferred.
8. **Q8 (new)** — Does a running script actually `load()` all 108 imported
   `.mesh` resources as `Mesh` (and is the scaffold `.ctex` material usable)?
   Sidecars and generated resources are present, but this proof is still
   UNVERIFIED and belongs to ticket C/D.
9. **Q9 (new)** — The aggregate OBJ SHA-256 printed in
   `BUILD_ART_BATCH_01.md` §4 (`3a7c2af…`) could not be reproduced from the
   current 108 OBJs with the four obvious name/bytes concat formulas tried
   here, so byte-identity of the aggregate is **not asserted** in this
   report. Per-file evidence used instead: all 108 source OBJ mtimes
   (12:07:39–12:09:56) predate this import run (12:22:22), and `git status`
   shows 0 modified tracked assets. `scaffold.png`'s individual SHA-256 *did*
   match the batch report exactly. If the batch owner can restate the
   aggregate formula, this question can be closed.

## 9. Summary

Ran **one** `stageimport01-import` job (ticket **534**) through
`variant3d/tools/godot_runner.py` with `--timeout 900 --max-wait 1800` and
the README's `--headless --path variant3d --import` flags. Result **ok**,
`exit` **0**, stderr **0 bytes**, queue wait **366.10 s**, Godot run
**159.55 s**. Godot 4.7.2 imported **109** files (108 stage OBJs +
`scaffold.png`). On-disk verification: `.obj.import` in `obj/` **172 → 280**
(+108, all 108 stage OBJs covered); **108 / 108** sidecars have non-empty
`path` and `uid` and resolve to non-zero `.mesh` resources; `scaffold.png.import`
created (946 B, valid `path`/`uid`); `.godot/imported/` gained **218** files
(108 `.mesh` + 108 `.md5` + 1 `.ctex` + 1 `.md5`). **No `.uid` sidecars were
created** by this Godot version. Source asset counts and `scaffold.png` bytes
are unchanged; no source asset, manifest, game code, test, config or `app/**`
file was edited by hand. Runtime `load()`-as-`Mesh`, visual A/B and donor
parity remain **UNVERIFIED — no parity claim**; BUILD-ART-C and BUILD-ART-D
are still outstanding.

*End of STAGE-IMPORT-01 report.*
