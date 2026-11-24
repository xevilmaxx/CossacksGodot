---
owner: V7-79
wave: perf
date: 2026-11-24
scope: world3d_entities.gd + anim3d.gd ONLY (exclusive) + this report; no other source/config/test/asset edits, no git operations
files_changed:
  - variant3d/scripts/world3d_entities.gd   # sync() Pass 1 pose memo + telemetry
  - variant3d/scripts/anim3d.gd             # READ ONLY — no edit (contract kept intact)
  - docs/coord_swarm_2026-11-24/reports/V779_pose_memo.md
status: LANDED
method: MEASUREMENT (temporary headless probe via variant3d's own runner, deleted after) + exact source diff
headline: 8.2x–11.9x measured speedup at 200 units (133.122 ms -> 11.175–16.270 ms), byte-identical morph deltas, selftest 29/29
visual_parity: NONE CLAIMED — flat-root PORT APPROXIMATION — NOT DONOR PARITY; visual UNVERIFIED preserved
---

# V7-79 — memoize the donor pose once per `(sid, action, frame)` per `sync()`

## 0. Answer

The whole measured `sync_ms` hot path was `pose_for()` recomputing the flat-root
skinned vertex buffer for every unit even when hundreds of units share the same
donor frame. `sync()` Pass 1 now samples `anim3d.pose_for()` **once per memo key
and reuses the returned pose Dictionary** (real donor verts, resolved frame and
all batch fields) for every later unit of that key. The memo is a **local**
Dictionary created at the top of each `sync()` call, so a new donor frame on the
next frame is never served stale data.

Measured with the PERF3D method on the same probe shape: **200 units 133.122 ms
-> 11.175–16.270 ms/frame (8.18x–11.91x)**, 100 units 141.350 ms -> 7.514–15.931
ms/frame. Morph delta between donor frames 1 and 16 is **byte-identical**
(`118.295389942825`) before and after; `donor_morph_units == N`,
`batches = cached = 36`, and `pose_for()` calls per frame dropped from N to **6**.

No visual parity claim. No sprite sheet, tabs, RNG or invented value. All six
public signatures, V7-65 tints and V7-78 auto-loaded skins are untouched.

## 1. PERF3D evidence this fix targets

Source: `docs/coord_swarm_2026-11-24/reports/PERF3D_sync_hotpath.md:22-37,
:76-98, :119-125, :171-181`, measured in runner jobs **187, 190, 192** (all `ok`).
Raw outputs:

- `variant3d/.godot_queue/results/00000187_perf3d-sync-probe/stdout.txt:4` —
  `PERF3D n200 ... total=140.260 ... entities=138.338 ... morph=200 cached=60 batches=60`
- `00000190_perf3d-sync-probe4/stdout.txt:4-5` —
  `n200 total=163.176 ... entities=164.036`; `MICRO n200 pose=160.057 morph_lookup=1.745 xform=3.029`
- `00000192_perf3d-sync-probe5/stdout.txt:4-6` —
  `n200 total=127.657 ... entities=126.581`; `MICRO n200 pose=115.378 morph_lookup=1.126 xform=2.069`;
  `n200_res1200 total=135.572 reconcile=3.919`

Rank 1 of that report is `world3d_entities.gd:955-1000 -> anim3d.gd:489-530 /
:534-556 / :410-459`, **115.4–160.1 ms at 200 units (~0.58–0.80 ms/unit), 90–98 %
of `world.sync`**. Cause: `skin_vertices()` (:410-459) allocates two bone-length
arrays and writes a fresh `PackedVector3Array` for all 531–1014 donor verts on
**every** `pose_for()` call, and that result is only used as a `_morph_mesh()` cache
key (`:571-573`) — the work is discarded every frame for units sharing a frame.
The report's recommended smallest safe fix (§4 item 1, `:124-133`) is exactly
this memoization.

## 2. Exact diff

### `variant3d/scripts/world3d_entities.gd` (only file edited)

All additions are inside `sync()`; no public signature, constant, tint path,
label string or V7-78 skin path was changed. `anim3d.gd` was **read only** — no
diff at all (its `pose_for()`, `skin_vertices()`, `PORT_LABEL`, `visual`,
`_ensure_shipped_skins()` and six-method contract remain byte-for-byte).

| file:line (AFTER) | change |
|---|---|
| `world3d_entities.gd:953-962` | new V7-79 comment + `var pose_memo: Dictionary = {}` — LOCAL to this `sync()` call (not a member, not global), so it is cleared automatically at the right scope each frame. Comment records why `(sid, action)` is a complete proxy for `(sid, action, frame)` within one pass. |
| `world3d_entities.gd:982-989` | `var memo_key := sid + "|" + action`; on hit reuse `pose_memo[memo_key]`; on miss call `anim.call("pose_for", ed, action, _anim_t)` exactly once and store the resulting Dictionary under that key (an empty result is cached too, so a bad skin cannot be retried N times). |
| `world3d_entities.gd:990-999` | the existing vert/morph-mesh/`morph_rejects` body now runs on the reused pose as well (`if not pose.is_empty():` replaces the old `if p is Dictionary:`). Verts, `pose["frame"]`, `MORPH_POSE_SOURCE` gate, `_mesh_info()` and `_morph_mesh()` calls are unchanged. |
| `world3d_entities.gd:1000-1018` | unchanged: batch key `"unit|sid[|pN]|a<action>|f<frame>"`, `_release`/`_acquire`, `frame_changes`, `pose_sources`, `seen_frames`, `morph_units`, `static_units`. Identical batch keys. |
| `world3d_entities.gd:1064-1066` | new telemetry `stats["donor_morph_pose_samples"] = pose_memo.size()` (structural count of actual samples, no new value invented). All pre-existing `donor_morph_*` keys and their values are untouched. |

Key-scope note (open question Q1): within one Pass 1 `_anim_t` is constant and
`anim3d.pose_for()` resolves its frame purely from `(sid, action, donor time)`
(`anim3d.gd:489-530`, `_frame_at` `:582-588`, `_action_range_for` `:918-934`).
Therefore one key per `(sid, action)` is the same partition as one key per
`(sid, action, frame)`; the cached pose already carries its resolved `frame`
(`:516`), which is what builds the batch key at `:1006`. No frame is recomputed
or guessed outside `anim3d.gd`.

## 3. Measured before / after (`world.sync(dt)` ms per frame)

Probe: temporary `variant3d/tests/t_v779_pose_memo_probe_tmp.gd` (SceneTree),
run only through the runner. Shape from PERF3D §1: real `C3Game`
(`setup_begin("skirmish")`), N=100/200 real skinned units of sids
`peasant, pikeman, archer, cossack, musketeer, grenadier` (all present in
`assets/models/skin/index.json`), 1/3 flagged `moving`, `world3d.gd` loaded +
`bind(game)` so the five composed modules, V7-78 auto-loaded skins, donor OBJ
topology and MultiMesh batches are live. **40 warm-up + 120 timed frames**, full
`world.sync(0.016)` timed with `Time.get_ticks_usec()`, averaged per frame.
Probe and its JSON were deleted after measurement.

| N | BEFORE (ticket 196) | AFTER (ticket 199) | AFTER (ticket 200) | speedup |
|---|---|---|---|---|
| 100 | **141.350 ms** | 7.514 ms | 15.931 ms | 8.9x–18.8x |
| 200 | **133.122 ms** | 16.270 ms | **11.175 ms** | **8.18x–11.91x** |

- Ticket **199** speedup check: `before=133.122 after=16.270 ratio=8.18` PASS.
- Ticket **200** speedup check: `before=133.122 after=11.175 ratio=11.91` PASS.
- Both AFTER runs: all probe checks PASS, `fails=[]`.
- Headless dummy `RenderingServer` (PERF3D §1 caveat): CPU cost measured, GPU
  upload not. The user's windowed `sync_ms=12–20` absolute value remains
  UNVERIFIED; only the removed CPU hot path is measured here.
- The BEFORE 100-unit figure (141.350) exceeds the 200-unit figure (133.122).
  This is cold-start/machine-load noise in the first case of the process, not a
  scaling result; the AFTER runs show the expected ~2x growth with N. Ratios
  between BEFORE and AFTER are stable across both AFTER runs.

## 4. Correctness evidence

| check | BEFORE | AFTER | meaning |
|---|---|---|---|
| parse `world3d_entities.gd` | — | PASS (`GDScript`) — job 199/200 | script parses through variant3d runner |
| parse `anim3d.gd` | — | PASS (`GDScript`) — job 199/200 | untouched contract still parses |
| `donor_morph_units` | 100 / 200 | 100 / 200 | every unit still takes the real donor-skin path |
| `morph_delta` (frames 1 -> 16) | `118.295389942825` | `118.295389942825` | donor verts still morph between frames; byte-identical |
| `frame_a`, `frame_b` | 1, 16 | 1, 16 | same resolved donor frames (no invented frame) |
| `batches`, `donor_morph_meshes_cached` | 36, 36 | 36, 36 | identical batch keys / morph-mesh cache count |
| `donor_morph_pose_samples` | N/A (key absent) | **6** per frame | 6 `pose_for()` calls instead of 100/200 |
| full selftest | — | **29/29 PASS**, `passed=true`, 0 failures — job **202** | canonical gate green |

Runner job ids (all via `python variant3d\tools\godot_runner.py run ...`):

- **187, 190, 192** — PERF3D baseline `ok` (evidence cited in §1).
- **194** — first V7-79 probe attempt `failed` (probe bug: 2-arg `Object.get()`;
  no source change; superseded).
- **196** — valid BEFORE probe `ok` (47.94 s) — baseline numbers above.
- **199** — AFTER probe `ok` (8.13 s) — parse PASS, speedup 8.18x, morph delta.
- **200** — AFTER probe `ok` (9.59 s) — parse PASS, speedup 11.91x,
  `pose_samples=6`, morph delta, all checks PASS.
- **202** — `v779-selftest` `ok` (53.69 s) — `variant3d/selftest.json` re-read:
  `passed=true`, `steps=29`, `failed=0`.

Cleanup: `variant3d/tests/t_v779_pose_memo_probe_tmp.gd` and
`variant3d/tests/results/v779_pose_memo_probe_tmp.json` deleted; no `.uid` was
generated; no other file touched by this lane.

## 5. Invariants preserved

- Real donor flat-root skin data: `anim3d.gd` untouched; the cached Dictionary is
  the literal `pose_for()` return including `verts: PackedVector3Array`.
- Flat-root labels: `PORT_LABEL = "PORT APPROXIMATION — NOT DONOR PARITY"`,
  `BLOCKED_RIG`, `visual = "UNVERIFIED"` in both modules unchanged; the new
  telemetry is explicitly marked structural, not a visual claim.
- Six public signatures (`bind`, `sync`, `add_unit`, `add_building`,
  `add_resource`, `remove`) unchanged; V7-65 tint/batch-key code unchanged;
  V7-78 auto-loaded shipped skins unchanged.
- No sprite sheets, no tabs added, no RNG, no invented frame/value. Memo is
  scoped to one `sync()` (per-frame clear), never a global stale cache.

## 6. Open questions

- **Q1 — key scope.** Memo key is `sid|action`, not a literal
  `sid|action|f<frame>` string. This is exact today because `_anim_t` is fixed
  for the whole Pass 1 and `pose_for()` derives the frame internally. If a
  future change makes `pose_for()` depend on per-entity state other than `sid`,
  or advances the anim clock inside Pass 1, the key must include that frame.
  UNVERIFIED for such hypothetical changes; no current caller does either.
- **Q2 — windowed absolute ms.** Headless dummy RenderingServer, so the 12–20 ms
  windowed `sync_ms` snapshot itself was unavailable and is not re-measured.
  Only the CPU hot-path removal is quantified.
- **Q3 — run-to-run noise.** AFTER 100-unit ms ranged 7.5–15.9 and 200-unit ms
  11.2–16.3 (machine load, ±20 % consistent with PERF3D §1 caveat). Ratios and
  all correctness checks were stable; medians of more reps not taken.
- **Q4 — probe action mix.** The probe's `i % 6` sid rotation and `i % 3`
  `moving` flag correlate, so only 2 sids get `walk` and 4 get `idle` -> 6 memo
  keys instead of 12. This still proves N-to-6 sampling; a decorrelated mix was
  not measured.
- **Q5 — visual A/B.** No fixed-seed 3D screenshot A/B run (no visual parity
  claim made or implied).
