# V7-41 — Independent read-only supervision of the atomic wave-7 phase-2 tree

**Role:** supervision atom V7-41 (READ-ONLY). No files edited except this report.
**Contract audited:** `docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md`.
**Task split:** `WAVE7_3D_VARIANT_CHARTER.md:93-103`.
**Date:** 2026-11-24.

> **IMPORTANT — moving target.** The tree was actively changing *during* this
> audit. Files appeared between successive snapshot commands (e.g. `camera3d.gd`,
> `hud3d_adapter.gd`, `world3d_fx.gd`, `t_fx3d.gd`, `t_render_mode.gd` all landed
> mid-audit). Everything below is an honest point-in-time snapshot, not a claim
> about the tree at some later moment. Re-verify before relying on a "MISSING".

---

## 1. Contract modules: what landed + API signature audit

Every signature below was taken from `grep` of `variant3d/scripts/*.gd`, not from
agent reports. Contract API names are from `V73_ATOMIC_CONTRACT.md:10-17`.

| Task | Expected file | Present? | API verdict (PRESENT / MISSING / WRONG_SIGNATURE) |
|---|---|---|---|
| V7-11 | `scripts/camera3d.gd` (extends Camera3D) | YES (landed mid-audit) | **PRESENT, 1 benign superset**: `bind(game: Object, view_scale: float=1.0)`; `var view_scale: float`; `world_to_px(world: Vector2)->Vector2`; `screen_to_world(screen: Vector2)->Vector2`; `clamp_pos()`; `get_view_rect()->Rect2`; `get_viewport_corners()->Array`; `zoom_step(notches: float, anchor: Vector2=INF)`; `set_zoom_target(target: float, immediate: bool=false, anchor: Vector2=INF)` — **extra 3rd optional `anchor`** vs contract `(target, immediate:=false)`; positional 1–2 arg calls remain compatible. All 8 required methods + `view_scale` found. |
| V7-12 | `scripts/picking3d.gd` (extends Node) | **NO** (at final snapshot) | **MISSING** — `bind`, `pick`, `pick_res`, `ground_point` not found anywhere; no file. |
| V7-13 | `scripts/world3d_terrain.gd` (extends Node3D) | YES | **PRESENT, exact**: `bind(game)`, `build()->bool`, `invalidate()`, `has_chunk_or_fallback()->bool`, `height_at_world(p: Vector2)->float` — all 5 match contract verbatim. |
| V7-14 | `scripts/world3d_entities.gd` (extends Node3D) | **NO** (at final snapshot) | **MISSING** — `bind`, `sync`, `add_unit`, `add_building`, `add_resource`, `remove` not found; no file. |
| V7-15 | `scripts/world3d_fx.gd` (extends Node3D) | YES (landed mid-audit) | **PRESENT, superset**: `bind(g)`, `sync(dt)`, `add_fx(pos, kind, life := -1.0)->Dictionary`, `draw_ghost(sid, pos, ok: bool)`, `draw_rally(pos, player: int)`. `add_fx` adds a default + return value; 3-arg calls still valid. |
| V7-16 | `scripts/world3d_fog.gd` (extends Node3D) | YES (landed mid-audit) | **PRESENT**: `bind(g)`, `sync(dt: float)`, exposed `fog_explored: PackedByteArray` and `fog_vis: PackedByteArray` (contract requires the arrays readable by HUD minimap). |
| V7-17 | `scripts/hud3d_adapter.gd` (extends Node) | YES (landed mid-audit) | **PRESENT, param-name drift**: `bind(p_cam, p_hud)` (contract `bind(cam, hud)` — positional compatible); `get_minimap_box()->Rect2`; `screen_to_world(screen)->Vector2`. |
| V7-18 | `scripts/anim3d.gd` (extends Node) | YES | **PRESENT**: `bind(game, entities)`, `play(e, action, t)`; `PORT_LABEL := "PORT APPROXIMATION — NOT DONOR PARITY"` present (contract's required disclaimer label). |

**Pre-existing `*3d*.gd` files that are NOT the contract atoms** (do not count as
landing the contract): `world3d.gd` (integration owner, still the 2D-contract
world), `terrain3d_sandbox.gd`, `heightmap_world3d.gd`, `heightmap3d_sandbox.gd`
(wave-6 G3-x proof/reference files). None expose the new atomic module APIs.

**Integration seams** (`WAVE7_3D_VARIANT_CHARTER.md:100-101`) are explicitly a
FOLLOW-UP batch and had NOT landed: no `render_mode`, `make_world3d()` or
`make_camera3d()` in `main.gd` (verified indirectly by `t_render_mode.gd`'s
source-inspection design; see §2).

---

## 2. Atomic test atoms: PASS/FAIL prints + deferred quit

Contract test list: `V73_ATOMIC_CONTRACT.md:26-30`. Hygiene rule audited: prints
`PASS`/`FAIL` and uses `call_deferred("quit", ...)`; **no bare `quit()`** in
`_initialize()` (Godot 4.7 hang hazard, as the tests themselves comment).

| Task | Expected test | Present? | PASS/FAIL prints | Exit hygiene |
|---|---|---|---|---|
| V7-31 | `tests/t_terrain3d.gd` | YES | YES (`T_TERRAIN3D %s %s - %s` per check + `RESULT:` summary) | `call_deferred("quit", 0 if _ok else 1)`; no bare quit. |
| V7-32 | `tests/t_camera3d.gd` | YES | YES (`PASS `/`FAIL ` helpers + `T_CAMERA3D PASS/FAIL n/m checks`; explicit `FAIL MODULE_MISSING`) | `call_deferred("quit", ...)` at both exits. |
| V7-33 | `tests/t_pick3d.gd` | YES | **NO STDOUT** — `check()` only appends to `_checks` and writes `res://tests/results/t_pick3d.json`; no `print(` call in the file at all. Runner log-based scoring will see no PASS/FAIL line. | `call_deferred("quit", ...)` at all exits; no bare quit. |
| V7-34 | `tests/t_entities3d.gd` | YES | YES (`CHECK PASS/FAIL name :: detail`; writes `v734_entities3d.json`) | `call_deferred("quit", ...)` at all exits. |
| V7-35 | `tests/t_fx3d.gd` | YES (mid-audit) | YES (`PASS `/`FAIL ` + `T_FX3D PASS/FAIL n/m checks`) | `call_deferred("quit", ...)`. |
| V7-36 | `tests/t_fog3d.gd` | YES | YES (`  PASS  `/`  FAIL  ` + `V736 FOG3D END status=...`) | `call_deferred("quit", ...)`; comment explicitly forbids bare quit. |
| V7-37 | `tests/t_render_mode.gd` | YES (mid-audit) | YES (`CHECK ... PASS/FAIL` + `T_RENDER_MODE PASS/FAIL n checks`) | `call_deferred("quit", ...)`. |

Notes:
- **No direct `quit(`** call was found in any of the 7 files (grep excluded
  comments and `call_deferred("quit"`). Hygiene requirement is met everywhere.
- Tests that depend on a missing module fail loudly with `MODULE_MISSING` rather
  than silently skipping — correct per contract. At snapshot time that applies
  to `t_pick3d.gd` (`picking3d.gd` absent) and `t_entities3d.gd`
  (`world3d_entities.gd` absent).
- `t_render_mode.gd` is a **source-inspection gate**: it intentionally emits
  `SEAM_MISSING` / FAIL until the follow-up integration owner adds
  `render_mode`, `make_world3d()`, `make_camera3d()` and the 3D branch to
  `main.gd`. Its failure is expected, not a test bug — but it means the final
  gate cannot go green until that separate batch lands.
- `tests/manifest.json` was **not modified** at final snapshot: still 24
  inherited 2D entries, **zero atomic tests registered**. `V738_manifest.md`
  reports "registered: NONE / all 7 pending" and says all 7 files were absent —
  that report is now **stale** (all 7 files exist on disk). Registration must be
  re-run by V7-38's owner before the final gate can pick up the atomic tests.

---

## 3. Runner status (both read-only `status` invocations)

Queues are **independent**: each runner has its own spool; the 3D one explicitly
reports `spool = ...\variant3d\.godot_queue`, while the 2D one advances
`app/.godot_queue/now_serving` (a tracked file — see §4).

### `python variant3d\tools\godot_runner.py status` — 3D queue, 3 snapshots
| Snapshot | serving | next | pending | completed | statuses | lock |
|---|---|---|---|---|---|---|
| early | 6 | 6 | 0 `[]` | 6 | failed 4, ok 2 | free |
| middle | 14 | 17 | 4 `[13,14,15,16]` | 13 | failed 8, ok 5 | free |
| final | 16 | 23 | 7 `[16..22]` | 16 | failed 10, ok 6 | **HELD (34.2s)** |

Spool: `C:\Users\...\cossacks-3-3\variant3d\.godot_queue`. Rising `failed` count
tracks module-dependent atomic tests running before their modules land.

### `python app\tools\godot_runner.py status` — 2D queue, 2 snapshots
| Snapshot | serving | next | pending | completed | statuses | lock |
|---|---|---|---|---|---|---|
| early | 1340 | 1340 | 1 `[1339]` | 245 | failed 74, ok 162, skipped 1, timed-out 8 | free |
| final | 1340 | 1340 | 0 `[]` | 246 | failed 74, ok 163, skipped 1, timed-out 8 | free |

Spool: `app/.godot_queue` (independent of `variant3d/.godot_queue`). The early
`now_serving=1340` with pending `[1339]` then drained to 0 is concurrent 2D
runner activity by another worker, not caused by these read-only `status` calls.

---

## 4. `git status --short` — edits outside my ownership (conflict scan)

Final snapshot:

```
 M app/.godot_queue/now_serving
 M docs/coord_swarm_2026-11-24/IMPROVEMENTS.md
 M docs/coord_swarm_2026-11-24/PROGRESS.md
 M docs/coord_swarm_2026-11-24/WAVE7_3D_VARIANT_CHARTER.md
?? docs/coord_swarm_2026-11-24/reports/V732_test_camera3d.md
?? docs/coord_swarm_2026-11-24/reports/V734_test_entities3d.md
?? docs/coord_swarm_2026-11-24/reports/V738_manifest.md
?? variant3d/scripts/{anim3d,camera3d,hud3d_adapter,world3d_fog,world3d_fx,world3d_terrain}.gd
?? variant3d/tests/{t_camera3d,t_entities3d,t_fog3d,t_fx3d,t_pick3d,t_render_mode,t_terrain3d}.gd
?? variant3d/tests/t_v715_parse_tmp.gd
?? variant3d/tests/results/{t_pick3d,t_terrain3d,v734_entities3d}.json
```

Assessment of each out-of-scope change:

- `app/.godot_queue/now_serving` (1339→1340): **outside variant3d/ and outside
  docs/**; it is the independent 2D runner's spool marker. Expected consequence
  of concurrent 2D jobs; not a source edit and not mine. **Flag: expected, no
  conflict.**
- `PROGRESS.md`, `WAVE7_3D_VARIANT_CHARTER.md`, `IMPROVEMENTS.md`: outside
  `reports/`, but coordinator-owned docs announcing the atomic launch (diffs
  show only the new "PHASE 2 ATOMIC SPLIT" / launch paragraphs). **Flag:
  expected coordination, no conflict.**
- New `variant3d/**` files and `reports/V7*.md`: other agents' owned deliverables
  — **not touched by me.**
- `variant3d/tests/t_v715_parse_tmp.gd`: untracked scratch/parse-probe artifact
  left in the test directory by an in-flight worker. **Flag: cleanup candidate,
  not a contract test.**
- **No conflict with this report's own path** was observed. `V741_atomic_supervision.md`
  existed nowhere before this write; no other agent edited it.
- The only `M` files under `docs/` are the three coordinator docs above; no
  agent has rewritten another agent's report in the observed snapshot.

---

## 5. Honest status table (point-in-time)

| Task id | Expected file | Present? | API / test OK? | Blocker |
|---|---|---|---|---|
| V7-11 | `variant3d/scripts/camera3d.gd` | YES | API **OK** (8 methods + `view_scale`; `set_zoom_target` has one extra optional `anchor`) | none observed; test depends on module now present |
| V7-12 | `variant3d/scripts/picking3d.gd` | NO | API **MISSING** | module not landed → `t_pick3d` fails MODULE_MISSING |
| V7-13 | `variant3d/scripts/world3d_terrain.gd` | YES | API **OK**, exact 5/5 | none observed |
| V7-14 | `variant3d/scripts/world3d_entities.gd` | NO | API **MISSING** | module not landed → `t_entities3d` fails MODULE_MISSING |
| V7-15 | `variant3d/scripts/world3d_fx.gd` | YES | API **OK** (`add_fx` superset) | none observed |
| V7-16 | `variant3d/scripts/world3d_fog.gd` | YES | API **OK** (bind/sync + both arrays) | none observed |
| V7-17 | `variant3d/scripts/hud3d_adapter.gd` | YES | API **OK** (`bind` param names differ, positional-compatible) | none observed |
| V7-18 | `variant3d/scripts/anim3d.gd` | YES | API **OK** + required approximation label present | donor rig semantics BLOCKED per V7-2; fallback label is correct |
| V7-31 | `variant3d/tests/t_terrain3d.gd` | YES | prints OK, deferred quit OK | none observed |
| V7-32 | `variant3d/tests/t_camera3d.gd` | YES | prints OK, deferred quit OK | module landed late; re-run needed |
| V7-33 | `variant3d/tests/t_pick3d.gd` | YES | deferred quit OK; **no stdout PASS/FAIL** (JSON only) | `picking3d.gd` missing + log has no PASS/FAIL line |
| V7-34 | `variant3d/tests/t_entities3d.gd` | YES | prints OK, deferred quit OK | `world3d_entities.gd` missing |
| V7-35 | `variant3d/tests/t_fx3d.gd` | YES | prints OK, deferred quit OK | module landed late; re-run needed |
| V7-36 | `variant3d/tests/t_fog3d.gd` | YES | prints OK, deferred quit OK | none observed |
| V7-37 | `variant3d/tests/t_render_mode.gd` | YES | prints OK, deferred quit OK | **integration seam absent** (`main.gd` has no `render_mode`/`make_*`); expected FAIL/SEAM_MISSING |
| V7-38 | `variant3d/tests/manifest.json` (+ `reports/V738_manifest.md`) | report YES, registration **NO** | manifest still 24 2D entries, 0 atomic tests registered | report's disk audit is stale ("all 7 absent"); must re-run registration now that 7 tests exist |
| V7-40 | `docs/.../reports/V74*.md` + `docs/variant3d/STATUS.md` | some V74 reports present; `docs/variant3d/STATUS.md` **absent** | docs incomplete | not all module/test reports landed at snapshot; `STATUS.md` not written |
| V7-41 | `docs/.../reports/V741_atomic_supervision.md` | YES (this file) | read-only audit complete | no edits to other files |

---

## Top 3 risks

1. **Two of eight contract modules still absent at snapshot** — `picking3d.gd`
   (V7-12) and `world3d_entities.gd` (V7-14). Their atomic tests can only report
   `MODULE_MISSING`; the 3D runner's failure count was already climbing
   (10 failed / 6 ok, 7 jobs pending, lock held at last check).
2. **Manifest registration is stale / absent.** `V738_manifest.md` declares all
   seven tests pending and "zero on disk", but all seven now exist;
   `manifest.json` registers none of them. Final gate will not discover the
   atomic tests unless V7-38 re-runs registration.
3. **End-to-end gate cannot pass without the deferred integration batch.**
   `t_render_mode.gd` intentionally FAILs with `SEAM_MISSING` because `main.gd`
   lacks `render_mode`, `make_world3d()` and `make_camera3d()`. Separately,
   `t_pick3d.gd` emits no stdout PASS/FAIL (JSON only), which can be misread by
   log-based scoring. Both need owner action outside this read-only atom.

*Additional caveat: the tree was still receiving files throughout this audit;
any MISSING above may have been filled seconds later. This report must not be
read as a final gate result.*
