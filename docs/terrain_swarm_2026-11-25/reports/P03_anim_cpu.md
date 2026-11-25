---
id: P03-ANIM-CPU
ticket: TERRAIN-SWARM-2026-11-25 / WAVE P / P03 (read-only animation/CPU audit)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P03_anim_cpu.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No donor GPU A/B frame and no fresh frame-time measurement exists. Every cost figure is DERIVED from source/JSON counts or INFERRED from cadence assumptions, labelled as such; nothing here is a measured FPS claim or a donor-parity claim. No code, test, config, shader or asset was edited."
---

# P03 — animation / CPU audit: flat-root morph sampling and its entity caller

## 0. Scope compliance

Read-only ticket. Exactly one file created (this report). `variant3d/scripts/anim3d.gd` was read in full and
`variant3d/scripts/world3d_entities.gd` at all relevant ranges; their callers
were traced through `variant3d/scripts/world3d.gd`, `main.gd`, and the on-disk skin JSON assets.
No Godot process started, no runner job submitted (WAVE G standing rule: only G04 runs jobs),
no backup needed (no edit). Inputs read: `docs/terrain_swarm_2026-11-25/CHARTER.md`,
`docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md`, and the historical measurement reports
`V779_pose_memo.md`, `PERF3D_sync_hotpath.md`, `PERF_3D_01.md` (quoted as *historical context*,
never as a fresh result).

**Ownership boundary.** P10 may edit `anim3d.gd` only (WAVE G charter :83). P11 owns
`world3d_entities.gd` (:84). This report therefore separates **P10-ready changes** (§4) from
**caller-side changes that require P11 / COORD routing** (§5) and never assumes P10 can edit the
caller.

---

## 1. OBSERVED — the exact per-frame path

### 1.1 Call chain (verified by direct read)

| Step | Site | What happens |
|---|---|---|
| 1 | `main.gd:1587` `_process(dt)` → `:1671` `world.sync(dt)` | one sync per rendered frame; `dt` is raw wall-clock delta, clamped only at `:1615`, **not** scaled by game speed, and `world3d.gd:683` still does `anim_t += dt` when the sim is paused. |
| 2 | `world3d.gd:682-695` `sync()` | `_update_view_rect()` at `:684` computes a view rect but it is **never passed to entities**; `entities.sync(dt)` at `:691` is unconditional. |
| 3 | `world3d_entities.gd:2014-2299` `sync()` | Pass 1 (`:2044-2127`) pose sampling + batch migration; Pass 2 (`:2129-2146`) transform writes; building stages (`:2151`); rotors (`:2158-2183`); fields (`:2196-2248`); stats (`:2254-2299`). |
| 4 | `world3d_entities.gd:2071-2080` | per unit: `anim.call("has_skin", sid)`, then `pose_memo` keyed `sid + "|" + action` (`:2073`), then ONE `anim.call("pose_for", ed, action, _anim_t)` per key (`:2077`). The memo is **local to this sync** (`:2041`) and discarded at return. |
| 5 | `anim3d.gd:489-530` `pose_for()` | `_ensure_shipped_skins()` (`:490`, guarded once), `_action_range_for()` (`:497`), `_frame_at()` (`:507`), `_morph_fields()` (`:509`), builds the returned pose Dictionary (`:511-527`), copies morph keys via `morph.keys()` (`:528-529`). |
| 6 | `anim3d.gd:534-556` `_morph_fields()` | for a registered skin calls `skin_vertices()` (`:547`); caches nothing. |
| 7 | `anim3d.gd:410-459` `skin_vertices()` | `_valid_skin()` (`:412`), bone loop `:427-430` (`_qmat` per bone), vertex loop `:445-458` (weighted skinning into a fresh `PackedVector3Array`). |
| 8 | `world3d_entities.gd:2085-2087`, `:1310-1397` | `_morph_mesh(sid, info, frame, action, verts)` — cached by `sid|action|f<frame>` (`:1310-1312`), so its heavy body (per-corner string keys at `:1348`, mesh build at `:1386-1387`) runs only on a cache miss. |
| 9 | `world3d_entities.gd:2129-2142` | Pass 2: for **every** slot, `_xf()` → `Transform3D` → `xforms[ix] = xf` → `mm.set_instance_transform(ix, xf)`. |
| 10 | `world3d_entities.gd:1551-1593` `_xf()` | per entity: `_world_pos()` → `game.call("height_at", p)` (`:1535`), `Basis().rotated(...).scaled(...)` (`:1592`), `Transform3D(...)` (`:1593`). |

`anim3d.gd`'s other public entry, `play()` (`:143-208`), is reached only through
`world3d.gd:741-744` `play_anim()`; a repo-wide grep finds **no caller of `play_anim()`**, so
`play()` is not on the per-frame path today. It still shares `_morph_fields()` with `pose_for()`.

### 1.2 Measured skin dimensions (OBSERVED from on-disk JSON, read this ticket)

| sid | bones | verts | exported frames | weight pairs |
|---|---:|---:|---:|---:|
| peasant | 20 | 577 | 30 | 584 |
| musketeer | 24 | 890 | 36 | 890 |
| pikeman | 20 | 733 | 36 | 735 |
| cossack | 19 | 692 | 24 | 696 |
| hussar | 21 | 684 | 24 | 686 |
| cannon | 3 | 736 | 12 | 736 |

`index.json` declares **55 entries** / 55 skin JSONs; `_ensure_shipped_skins()` (`anim3d.gd:742-765`)
parses the index plus each asset once, guarded by `_shipped_loaded` (`:743-745`). It is called from
`bind()` (`world3d_entities.gd` does not call it; `world3d.gd:650` does), `has_skin()` (`:314`),
`pose_for()` (`:490`) and `play()` (`:144`). **After the first call it is a single bool test — there
is no per-frame disk I/O in anim3d.gd.** The one-time 56-file JSON parse is a startup cost
(P06 territory), not a steady-state cost.

### 1.3 Historical telemetry (OBSERVED in old reports, NOT re-measured here)

- `V779_pose_memo.md:28-32,85-107`: at N=200 headless units, `pose_for()` per unit cost
  133.122 ms → 11.175–16.270 ms after the caller-side memo; a micro line reported
  `pose=115.378–160.057 ms` for **200 separate calls**, i.e. ≈**0.58–0.80 ms per pose sample**
  (DERIVED). `pose_samples` dropped from 200 to **6**; morph delta byte-identical.
- `PERF_3D_01.md:40,140-143`: on the current 240² build, `sync_ms` = 276.77 / 272.56 ms
  (jobs 477/500, mean 274.665 ms), ~2.04× a 134.54 ms older window; per-stage timing
  and live-unit count are **not emitted** (`:101`, `:132`, `:101-105`).

These numbers are quoted only to size the *remaining* target. They are not current FPS and
are explicitly UNVERIFIED for today's tree.

---

## 2. DERIVED — cost model (loops × entities × transforms)

Let:

- **U** = unit slots in `_slot` (Pass 1, `:2044`)
- **N** = all slots in `_slot` (Pass 2, `:2129`) = U + resources
- **G** = building nodes in `_nodes` (`:2143`)
- **K** = distinct `(sid, action)` keys in one sync = `pose_memo.size()` (`:2041`, telemetry `:2282`)
- **B_s / V_s / W_s** = bones / verts / weight pairs of skin `sid` (§1.2)
- **f_render** = rendered frames/s, **f_donor = 30** (`anim3d.gd:59`, `DONOR_FPS`)

### 2.1 Per-sync operation ledger (all counts are OBSERVED code multiplicities)

| # | Loop / site | Iterations per `sync()` | Per-iteration work | Label |
|---|---|---|---|---|
| 1 | Pass 1 per unit `:2044-2127` | **U** | `_measure_speed` (1 `{pos,t}` Dict at `:1236`), `_smooth_face` (`:1244`), `_unit_action` (`:1197`), `fposmod` yaw check (`:2064`), `has_skin` dynamic call (`:2072`), one `sid+"|"+action` String (`:2073`), one `_morph_mesh` key String (`:1310`), 2–3 `+=` String builds for `new_key` (`:2094-2098`) | OBSERVED |
| 2 | `pose_for` calls `:2077` | **K** (≤ U) | see §2.2 | OBSERVED |
| 3 | `_morph_mesh` body `:1313-1397` | **F** = distinct `sid|action|frame` ever seen, cumulative (`_morph_meshes`, `:2285`) | per corner: `str(vi)+","+str(ui)` Dict key (`:1348`), Packed arrays (`:1336-1338`), normals loop (`:1372-1385`), `ArrayMesh.new()` (`:1386`) | OBSERVED; warm-up only after cache fills |
| 4 | Frame-change batch migration `:2099-2105` | **U** per donor-frame change | `_release` (swap-remove + `mm.set_instance_transform`, `:1490-1502`), `_acquire` (new slot Dict `:1464`, `Transform3D()` append `:1461`), `pose_info` Dict (`:2101`) | OBSERVED |
| 5 | Pass 2 slot loop `:2129-2142` | **N** | `_xf()` → `height_at` dynamic call (`:1535`) + `Transform3D` (`:1593`) + `xforms[ix]=` + **`mm.set_instance_transform()` FFI (`:2142`)** | OBSERVED |
| 6 | Building loop `:2143-2146` | **G** | `_xf()` + `mi.transform =` | OBSERVED |
| 7 | Field loop `:2210-2248` | instances of `res|field` | 2 `game.call()` (`:2217,:2219`), `Color` (`:2222-2239`), `_xf()` + `Transform3D` (`:2243-2244`), 2 MultiMesh FFI writes (`:2246-2247`) | OBSERVED |
| 8 | Rotor loop `:2163-2183` | `_rotors.size()` | camera basis math + `Transform3D` (`:2180`) | OBSERVED |

### 2.2 One `pose_for()` sample — exact allocation / arithmetic count

For a skin with B bones, V verts, W weight pairs (peasant 20/577/584):

| Site | Allocations | Scalar work |
|---|---|---|
| `anim3d.gd:149` `skin: Dictionary = {}` | 1 Dict | — |
| `:497` `_action_range_for` | 1 Array (`[...]` at `:930`, or `.duplicate()` at `:934`) | ≤1 `rfind`/`substr` |
| `:507` `_frame_at` | 0 | `fposmod`, `floor`, `maxi` |
| `:509`→`:534` `_morph_fields` | 1 Dict (`:548`), plus skin_vertices below | — |
| `:412` `_valid_skin` | 0 | 9-key `has` loop + 4 size checks (`:631-649`) |
| `:421` `_nearest_local` (compact only) | 0 | linear scan over `frames` (24–36 entries, §1.2) |
| `:423-426` `mats` / `poss` | 2 Arrays sized B | — |
| `:427-430` bone loop | **B** × `_qmat` → **B `PackedFloat32Array(9)`** (`:603`) + B `Vector3` | B × ~9 mults in `_qmat` (`:594-603`) |
| `:443-444` `out` | 1 `PackedVector3Array` sized V | — |
| `:445-458` vertex loop | V `Vector3` writes | **W** inner iterations × (9 packed-array reads `m[0..8]` + ~12 float ops) ≈ **9W ≈ 5,256 reads / ~7k scalar ops** for peasant |
| `:511` returned `out` Dict | 1 Dict (15 keys) + 1 `range` Array (`:519`) | — |
| `:528-529` `morph.keys()` | 1 Array of keys + loop | — |

**Per sample (peasant): ≈ B + 9 ≈ 29 heap allocations**, dominated by 20 `_qmat` packed arrays
and one 577-element `PackedVector3Array`; ≈7k scalar float ops. (DERIVED from OBSERVED code and
JSON dimensions.) At 6 samples/frame (`V779_pose_memo.md:123`) that is ≈174 heap allocations and
≈42k scalar ops per frame — DERIVED, historical key count.

### 2.3 Scale examples (DERIVED; f_render assumed 60 — UNVERIFIED on this machine)

| Workload | U (OBSERVED source) | K | `mm.set_instance_transform`/s (`:2142`) | pose samples/s | pose samples/s that are redundant if donor frame unchanged |
|---|---:|---:|---:|---:|---:|
| V7-79 probe | 200 (`V779_pose_memo.md:28`) | 6 (`:123`) | 12,000 | 360 | ≈180 (INFERRED) |
| mass-army test | 552 (`t_mass_army.json:37`) | unknown (UNVERIFIED) | 33,120 | 6×f_render if K=6 | ≈50% of them (INFERRED) |
| sim-scale test | 3,000 (`t_perf_scale.json:27`) | unknown | 180,000 | unknown | unknown |

The `t_perf_scale` / `t_mass_army` counts are real entity counts from **sim-only** probes; they
are used only as scale inputs for the render-sync formulas, not as render measurements.

### 2.4 Why idle frames are recomputed (INFERRED, cadence-based)

`_frame_at()` (`anim3d.gd:582-588`) maps time to donor frame at 30 fps; `idle` spans frames
64–113 (`:72`, 50 frames ≈1.67 s). At f_render=60, `t` advances by ~1/60 s per sync, so
`floor(t*30)` changes every **second** frame — roughly **50 % of all `pose_for()` calls resolve a
frame identical to the previous call** and would return byte-identical verts. At f_render=30
~0 % is redundant; at 120 ~75 %. The `pose_memo` in the caller is scoped to one sync (`:2041`),
so it cannot exploit this. **Exact rate UNVERIFIED without an FPS/capture measurement** (P09).

Paused game: `main.gd:1615` clamps dt but `world.sync(dt)` is still called at `:1671`, and
`world3d_entities.gd:2019` does `_anim_t += maxf(dt,0)` unconditionally. Animation work therefore
continues at full rate while the sim is paused (OBSERVED code; cost impact INFERRED).

### 2.5 Off-screen units (OBSERVED absence of culling)

`world3d.gd:684` computes `view_rect`; `world3d_entities.gd:2014-2299` never reads it, a camera
and viewport are fetched only for rotor billboarding (`:2159-2162`), and `_is_hidden()` (`:1539-1548`)
covers only dead/exhausted-resource entities. Therefore **all U units** are sampled, migrated and
transform-written every frame regardless of visibility. The savings from culling are proportional
to the off-screen fraction of units and to how many distinct `(sid, action)` keys exist only
off-screen — both UNVERIFIED without a live scene/camera probe.

---

## 3. RANKED findings (highest expected cost first; all savings INFERRED unless stated)

| Rank | Finding | Evidence | Who can fix | Expected reduction | Label |
|---:|---|---|---|---|---|
| **F1** | **Unconditional per-slot transform write** — every N slots get `height_at` + `Transform3D` + `set_instance_transform` every frame, including idle/static units | `world3d_entities.gd:2129-2142`, `:1551-1593`, `:1535` | **P11 only** (P10 cannot edit this file) | O(N·f_render) FFI writes eliminated when pos/face/hidden unchanged; at U=552/f=60 = 33,120 writes/s → potentially near zero for static armies. Magnitude UNVERIFIED | OBSERVED code, INFERRED saving |
| **F2** | **Frame-keyed batch churn** — `new_key` contains the donor frame, so every donor frame change releases+reacquires every unit | `:2094-2105`; `_release :1475-1513`; `_acquire :1443-1472` | **P11 only** | O(U·30) release/acquire pairs/s (≈16.6k/s at U=552) removed; replace with per-batch `mm.mesh` swap (pattern already at `:2113-2120`) | OBSERVED code, INFERRED saving |
| **F3** | **Per-key pose re-skin every sync even when donor frame is unchanged** — no cross-frame cache in `anim3d.gd`; caller memo is per-sync only | `anim3d.gd:489-530`, `:534-556`, `:410-459`; `world3d_entities.gd:2041` | **P10** (this ticket's target) | ~50 % of K skinning calls at f_render=60 (INFERRED); historically ≈0.58–0.80 ms/sample at 200 units → ≈1.7–2.4 ms/frame saved at 200 units (DERIVED extrapolation, UNVERIFIED now) | OBSERVED code, INFERRED/UNVERIFIED saving |
| **F4** | **Off-screen units fully processed** — no view-rect/frustum gate before pose sampling or transform writes | `world3d.gd:684` vs `world3d_entities.gd:2014-2299` | P11 + `world3d.gd` owner (COORD routing) | Removes U_off-screen work; fraction UNVERIFIED | OBSERVED absence, UNVERIFIED saving |
| **F5** | **Allocation churn inside each `pose_for` sample** — ~B+9 heap allocations, incl. B `_qmat` packed arrays and a `morph.keys()` Array | `anim3d.gd:149,173,183,423-459,511,519,528-529,593-603` | **P10** | ~50 % reduction on unchanged frames via F3; extra few allocations removed by §4-C. GC pressure INFERRED | OBSERVED code, INFERRED saving |
| **F6** | **Per-unit micro-work in Pass 1** — `has_skin` dynamic call, `sid+"|"+action` strings, `{pos,t}` Dict, `_morph_mesh` key string | `world3d_entities.gd:1236,2072-2073,1310,2094-2098` | **P11 only** | O(U·f_render) small allocations; microseconds each, aggregate unknown | OBSERVED code, UNVERIFIED saving |
| **F7** | **One-time 56-file JSON parse at bind** — index + 55 skins parsed synchronously | `anim3d.gd:742-765,771-888`; `index.json` 55 entries | P06 / P10 (startup, not per-frame) | Startup hitch only; no steady-state gain | OBSERVED code, UNVERIFIED cost |

**Important framing for COORD:** F3/F5 are the only items P10 can address. Historical V7-79
already removed the *per-unit* duplication (8–12× measured then); P10 removes only the residual
*per-key, per-frame* recomputation. It cannot by itself explain today's ~274 ms `sync_ms`
(`PERF_3D_01.md:140`) — F1/F2/F4 in `world3d_entities.gd` are ranked higher and belong to P11.
Per-stage attribution remains BLOCKED (`PERF_3D_01.md:101`), so all savings here stay INFERRED.

---

## 4. Exact P10 changes — `variant3d/scripts/anim3d.gd` ONLY

No signature, label, PORT APPROX status, donor citation, skin math, frame rule or test is weakened.
All changes must be byte-identical in output on a cache miss.

### 4-A (PRIMARY, rank F3): cross-frame last-frame morph cache in `_morph_fields()`

**Why here:** `_morph_fields` is the only place that calls `skin_vertices()` (`:547`) and is
shared by both `pose_for()` (`:509`) and `play()` (`:165`). Caching it removes the dominant work
for both, without changing who owns the returned pose Dictionary.

Insert after `:124` (`_shipped_error` declaration):

```gdscript
# "<sid>|<frame>" -> {"frame": int, "morph": Dictionary}. One entry per live
# (sid, frame), NOT per skin frame set: bounded by active keys, not by 55 skins.
var _morph_lrfu: Dictionary = {}
```

Change the internal signature at `:534` to `func _morph_fields(skin: Dictionary, frame: int, sid: String = "") -> Dictionary`
(both call sites are in this file: `:165` has `sid` at `:148`; `:509` has `sid` at `:493` — pass it).

At the top of `_morph_fields`, after the existing empty-skin early return (`:535-544`), add:

```gdscript
var ck := sid + "|" + str(frame)
var hit: Dictionary = _morph_lrfu.get(ck, {})
if not hit.is_empty() and int(hit.get("frame", -2147483648)) == frame:
    return hit["morph"] as Dictionary
```

Before each return of a non-empty morph result (the `:548-556` literal), store it:

```gdscript
var morph := { ... }   # existing :548-556 literal, unchanged
_morph_lrfu[ck] = {"frame": frame, "morph": morph}
return morph
```

For an empty skin, do **not** cache (avoid holding an empty-skin entry across a later
`register_skin()`); the existing early return stays as-is.

**Invalidation (mandatory — stale verts otherwise):**
- `register_skin()` `:309` after `_skins[key] = norm` → `_morph_lrfu.clear()`
- `unregister_skin()` `:319` after `_skins.erase(...)` → `_morph_lrfu.clear()`
- `_load_shipped_skin()` `:887` after `_skins[sid] = skin` → `_morph_lrfu.clear()`
- end of `_ensure_shipped_skins()` `:765` → `_morph_lrfu.clear()` if `_shipped_count` changed during the loop (defensive; normally load happens at `bind()` before any pose).

**Bounding:** cap `_morph_lrfu` at 512 entries (a `clear()` on overflow) so a pathological
many-sid/many-frame session cannot retain unbounded packed arrays. Normal steady state is K
entries (historical K=6, `V779_pose_memo.md:123`); each holds one `PackedVector3Array` of V
vectors (peasant ≈7 KB), i.e. ≈40 KB at K=6 — DERIVED from §1.2.

**Expected cost reduction:** on a hit, `_valid_skin` (`:412`), `_nearest_local` (`:421`), both
bone arrays, B `_qmat` allocations, the V-element `out` array, the W-pair inner loop and the
morph Dict allocation all disappear. At f_render=60 / 30 Hz donor, ~50 % of samples hit
(INFERRED); using the historical ≈0.58–0.80 ms/sample (§1.3) this is ≈1.7–2.4 ms/frame at
200 units — **INFERRED extrapolation, UNVERIFIED for this tree/machine**. On a miss the code
path is identical, so verts/frame/labels are byte-identical.

**Immutability contract:** callers must treat the returned `verts`/pose as read-only. Both current
callers only read (`world3d_entities.gd:2082-2087`, `:2101-2104`; `play()` publishes to meta at
`:958-962`). Do **not** `duplicate()` the verts on return — that would defeat the cache.

### 4-B (secondary, rank F5): trim `pose_for()` per-call allocations

All in `anim3d.gd`, no behaviour change:

| Site | Change | Saving |
|---|---|---|
| `:149` `var skin: Dictionary = {}` | `var skin: Dictionary = _skins.get(sid, {})` | removes one empty-Dict allocation per sample when a skin exists |
| `:528-529` `for key in morph.keys(): pose[key] = morph[key]` | `pose.merge(morph)` (native Dictionary merge; `morph` keys are all plain data) | removes one keys Array + GDScript loop per sample |
| `:183-184` `for key in morph.keys()` in `play()` | same `pose.merge(morph)` | same, for the non-hot caller |
| `:519` and `:195` `"range": [first, last]` | build one local `var rng := [first, last]` and reuse it in the returned Dict | removes one Array per sample |
| `:934` `(AAF_ACTIONS[action] as Array).duplicate()` | cache the duplicate in a module-level Dict keyed by action (AAF_ACTIONS is a const) | removes one Array per sample for non-compact skins (rare in shipped runtime; all 55 shipped skins are compact) |

Expected: ~4 fewer allocations per sample; small relative to 4-A (INFERRED). Keep `ACTION_ALIAS`,
`PORT_LABEL`, `BLOCKED_RIG`, `visual`, `loop` and all donor strings byte-identical.

### 4-C (optional, rank F5): remove per-bone `_qmat` allocations on a cache miss

`_qmat()` (`:593-604`) allocates a new `PackedFloat32Array([...])` for every bone on every
skin_vertices call (B=20–24 per sample). Either:
1. add an optional `out: PackedFloat32Array` parameter filled in place, and keep module-level
   scratch `_qmat_out: Array[PackedFloat32Array]` sized to B; or
2. at skin load (`:824-839`), precompute `mats` for all `nf` frames and store under a new skin key,
   so `skin_vertices():427-430` just copies/reads them.

Option 2 costs ≈B×frames×9×4 B ≈21.6 KB/skin for peasant ×55 skins ≈1.2 MB (DERIVED), but
requires careful verification that the shipped compact-frame mapping (`:421`, `:893-912`) is
unchanged. **Defer until 4-A is measured** — 4-A already removes these calls on ~50 % of frames.

### 4-D (explicitly NOT in P10)

The following need `world3d_entities.gd` (P11) or `world3d.gd`; do not attempt them in P10:
Pass 2 dirty-transform gating (F1), frame-key batch removal (F2), view-rect culling (F4),
`has_skin`/string-key reductions (F6). See §5.

### 4-E: P10 verification contract (no runner by P03/P10 analysis)

- `skin_vertices()` / `pose_for()` outputs on a forced cache miss must be byte-identical to
  today (same `verts`, `frame`, `sample_frame`, `pose_source`, `frame_clamped`, labels).
- `stats["donor_morph_pose_samples"]` (`world3d_entities.gd:2282`) must keep counting **caller**
  memo keys — do not change that telemetry. Optionally add a P10-local stat for cache hits,
  but do not weaken/remove any existing key.
- No test assertion may be relaxed. The only direct pose_for test is
  `t_motion_capture.gd:234-235`; structural morph tests read `stats` but none assert an exact
  `pose_samples` value (verified by grep of `variant3d/tests`).
- Backups required before the edit: `inbox/backup/anim3d.gd.bak-P10` (WAVE G charter :87).

---

## 5. Caller-side proposals for P11 / COORD (NOT P10-owned)

These are the higher-ranked F1/F2/F4/F6 items. Listed with exact sites so COORD can route them
to P11, whose exclusive file is `world3d_entities.gd`.

1. **F1 — dirty transform writes.** `sync()` Pass 2 `:2129-2142` currently calls `_xf()` and
   `set_instance_transform()` for every slot every frame. Add a per-id mirror of the last written
   `(pos, face, hidden, jitter, y)` (the sim fields `_xf()` reads at `:1556-1592`) and write only
   on change; keep an unconditional write when `_acquire()` created a new slot (`:1443-1472`
   appends an identity `Transform3D` at `:1461` and does **not** write it — Pass 2 is currently
   the only writer). Preserve field pulse colour writes (`:2232-2247`) and rotor billboarding.
2. **F2 — remove the frame from the batch key.** `:2094-2098` builds
   `unit|sid[|pN]|a<action>|f<frame>`; every donor-frame change forces `_release`+`_acquire`
   for every unit (`:2100-2104`). Keep the key as `unit|sid[|pN]|a<action>` and swap the batch
   mesh once per `(sid, action, frame)` via the existing frozen-refresh pattern at `:2113-2120`;
   update `_applied_pose_frame` (`:2122`) accordingly. This removes O(U×30) Dict/String/Transform
   churn per second.
3. **F4 — off-screen gating.** Thread `world3d.gd:684`'s `view_rect` (or a camera frustum) into
   `entities.sync()` and skip pose sampling for keys whose units are all off-screen, retaining
   the last pose from P10's cache until a unit becomes visible. Needs coordination with the
   `world3d.gd` owner; visual correctness UNVERIFIED without a capture.
4. **F6 — hoist `has_skin` out of the unit loop.** `:2072` issues U dynamic `call()`s per frame;
   cache the set of skinned sids once (or expose a bulk `anim.has_skin_batch()` from P10) and
   reuse `pose_memo` keys. Micro-optimisation; rank last.

---

## 6. Allocation ledger summary (OBSERVED multiplicities, DERIVED counts)

| Object | Per frame | Source | Removed by |
|---|---|---|---|
| `{pos,t}` Dict | U | `world3d_entities.gd:1236` | P11 |
| `sid|action`, `sid|action|f<frame>`, `unit|...` Strings | ≥3U | `:2073,:1310,:2094-2098` | P11 |
| slot Dictionary on frame change | U × 30/s | `:1464` | P11 (F2) |
| `Transform3D` | N + G + fields + rotors | `:1593,:2146,:2243,:2180` | P11 (F1) |
| `pose_for` Dicts / Arrays | ≈4 per sample × K | `anim3d.gd:149,497,511,519,528` | P10 §4-B |
| `_qmat` `PackedFloat32Array(9)` | B per sample | `anim3d.gd:603` | P10 §4-A (on hit), §4-C (on miss) |
| skinned `PackedVector3Array[V]` | 1 per sample | `anim3d.gd:443-458` | P10 §4-A (on hit) |
| morph Dict | 1 per sample | `anim3d.gd:548` | P10 §4-A (on hit) |

---

## 7. UNVERIFIED / open register

1. No fresh FPS, frame time or per-stage timing was run (ticket rule); all savings are INFERRED.
2. f_render on this MX130/windowed setup is unknown (P09 must measure). The 50 % idle-frame
   redundancy figure assumes 60 fps and a 30 Hz donor clock.
3. K (distinct `sid|action` keys) on a real map is unknown; historical probe K=6 at N=100/200
   with a specific sid/action mix (`V779_pose_memo.md:169-172`).
4. Off-screen unit fraction and the number of off-screen-only keys are unknown.
5. Whether the current ~274 ms `sync_ms` (`PERF_3D_01.md:140`) still contains a material pose
   component is unknown: no per-stage hook exists (`:101`), and V7-79's 8–12× is historical.
6. Donor visual parity remains UNVERIFIED throughout (CHARTER §3); flat-root morph is
   `PORT APPROXIMATION — NOT DONOR PARITY` (`anim3d.gd:63`).
7. `play()` is currently unreferenced; if a future caller uses it, the §4-A cache covers it via
   `_morph_fields`, but the published pose Dict would be a fresh object (no shared-meta mutation).

## 8. Bottom line for COORD

- The largest two animation-adjacent costs are in **P11's file**, not P10's: unconditional
  per-slot transform writes (F1) and frame-keyed batch release/acquire churn (F2).
- P10's real remaining target is **F3**: a cross-frame, last-frame morph cache in
  `anim3d.gd:_morph_fields()` (§4-A), worth roughly half of the current per-key skinning work
  at 60 fps (INFERRED), plus small allocation trims (§4-B). It does not change any donor frame,
  vert, label or test.
- No number in this report is a measured FPS improvement. P09's capture/telemetry plan must
  precede any LANDED cost claim.

*End of P03 report.*
