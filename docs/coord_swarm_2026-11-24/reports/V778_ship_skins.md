---
id: V7-78
owner: V7-78
date: 2026-11-24
mode: "atomic builder — 1 owned code file edited + 1 new converter tool + NEW donor-derived skin assets + 1 report; temporary probe created, run, then deleted"
owns: ["variant3d/scripts/anim3d.gd", "variant3d/tools/convert_skins.py", "variant3d/assets/models/skin/**", "docs/coord_swarm_2026-11-24/reports/V778_ship_skins.md"]
scope: "SINGLEPLAYER SKIRMISH ONLY — ship donor-derived skin/pose assets that anim3d.gd loads automatically, with no manual probe registration; no campaign, DLC, network, 2D bake or sprite sheets (WAVE7_3D_VARIANT_CHARTER.md:37-53)"
governing_rule: "Leverage existing DONOR code; cite donor path:line; mark unreadable semantics UNVERIFIED (WAVE7_3D_VARIANT_CHARTER.md:29-36; AUDIT3D_CHARTER.md:6-15)"
donor: "C:\\Games\\Cossacks 3 (private use; bytes/ASCII read-only; no donor binary run, no donor bytes in repo)"
contract: "V7-64/V7-74 signatures unchanged; no edit to world3d_entities.gd, world3d.gd, main.gd, app/, config, tests or selftest source; no git operations"
no_rng: true
tabs: true
sprite_sheets: false
bake_outputs: false
godot_runs: "variant3d/tools/godot_runner.py ONLY — ticket 176 (v778-anim3d-parse, ok 2.26 s); ticket 184 (v778-anim3d-parse-final, ok 5.41 s); ticket 178 (v778-auto-skin-probe, TIMED OUT — probe bug, superseded); ticket 180 (v778-auto-skin-probe2, ok 3.68 s, 21/21); ticket 181 (v778-auto-skin-probe3, ok 3.13 s, 24/24 FINAL); ticket 186 (v778-selftest, ok 52.39 s, passed:true 29/29). See §5."
status: "IMPLEMENTED — shipped donor-frame SUBSET skins auto-register on first anim3d call; 733/733 rendered verts change with NO manual registration; PORT APPROXIMATION — NOT DONOR PARITY retained; visual = UNVERIFIED; no visual-parity claim"
---

# V7-78 — ship donor-derived skins so morphs happen in the runtime

## 1. Honest verdict up front

- **DONE, THE CAVEAT IS CLOSED.** V7-74 (`V774_consume_poses.md:39-42`, §7 Q1
  `:173-178`) proved the renderer morphs when a skin is registered, but warned
  that no skin is registered in shipped play. This pass writes 55 converted
  donor skins into `variant3d/assets/models/skin/` and makes `anim3d.gd`
  auto-load them on its first `bind()` / `has_skin()` / `pose_for()` call. A
  temporary probe added a unit by the real roster sid `peasant` through
  `world3d_entities.gd`, called `sync()` at two donor frame times and measured
  **733/733 rendered corners change** with **zero** `register_skin()` calls in
  the probe (§5).
- **DONOR-GROUNDED, NOT INVENTED.** Every number comes from the manifest's donor
  `.oss` path + the unit's own donor `.aaf` file, translated with the copied
  `bake_sprites` reader/skin math. Export is a deterministic **subset** of real
  donor frames (§3); no frame index or keyframe is invented and no 2D bake, PNG
  or sprite sheet is produced.
- **STILL NOT DONOR PARITY.** Flat-root skin only (donor bone parents unreadable
  — V7-2 §3.3 / Table B1). Shipped frames are the exported subset, snapped by
  nearest donor frame with **no interpolation** (§3.4). Normals are generated
  from morphed faces; donor→Godot quaternion convention is still uncited.
  Every status keeps `PORT APPROXIMATION — NOT DONOR PARITY` and
  `visual = "UNVERIFIED"`. No screenshot or donor A/B was made.
- **NO ENTITY/WORLD EDIT NEEDED.** `world3d.gd:466` instantiates anim3d and
  `:503` calls `anim.bind(game, entities)`; `world3d_entities.gd:970-971` calls
  `anim.has_skin(sid)` and `sync()` calls `pose_for()`. Both now trigger the lazy
  auto-load, so the shipped composition needs no handoff change. Those files
  were **not** edited.

## 2. Donor citations (all private-use, read-only)

| Donor fact | Citation | Where used |
|---|---|---|
| `.oss` `<6i k,fps,b,v,fc,t>` header; verts/weights/flat bone tracks | `docs/decomp/DC_FORMATS.md:44,46-64`; `variant3d/tools/bake_sprites.py:91-103`; `convert_models.py:48-71` | converter `read_oss()` `:81-115` (exact byte closure checked) |
| AAF dialect, inclusive ranges | `docs/decomp/DC_FORMATS.md:96-109`; `data/animations/aaf/peaukr.aaf:1-20` | converter `read_aaf()` `:118-137`; anim3d `AAF_ACTIONS` `:71-90` |
| **Per-unit** AAF differs from peaukr | `data/animations/aaf/musketeer.aaf:3-9` (`walk 1..24`, `idle 153..202`); `pikeman.aaf:3-8` (`death 80..134`); `officer.aaf:3-6` (`idle 115..164`); `hussar.aaf:3-6` | exported per sid from its own AAF and carried in the asset `actions{}`; `pose_for` uses it via `_action_range_for()` `:918-935` |
| `qmat` transposed + flat-root `skin` | `bake_sprites.py:118-129`, `:131-143` | converter `qmat()` `:152`, `skin_at()` `:162-175` (evidence only); runtime `anim3d._qmat()` `:593-605`, `skin_vertices()` `:410-462` |
| Donor-order frame decimation, Python `round()` half-to-even | `bake_sprites.py:145-152` | converter `sample_frames()` `:140-149`; runtime `anim3d.sample_frames()` `:465-480` / `_py_round_i()` |
| Manifest sid → donor `.oss` source path | `variant3d/assets/models/manifest.json` `models[].mesh`; mapping established in `V763_missing_models.md:122-153` | converter `main()` `:271-308` iterates all 62 unit entries |
| Morph index `i` == shipped OBJ vertex `i` | `bake_sprites.py:94`; `convert_models.py:43-66,109-125`; `V764_donor_morph_anim.md:58` | `MORPH_COORD` `anim3d.gd:106`; V7-74's `_morph_mesh` topology match |
| Bone parents unreadable | `V72_mesh_conversion_feasibility.md:180-186,264-284`, Table B1 `:380-386`; `AUDIT3D_08:56,98` | `BLOCKED_RIG` `anim3d.gd:66`; converter `BLOCKED_RIG` `:62` |

Measured peaukr header re-confirmed this pass: `k=483, fps=30, b=20, v=577,
fc=921, t=733`, 312,376-byte exact closure (`DC_FORMATS.md:62`; `V764 §5`).

## 3. Converter design and frame selection

### 3.1 Why a subset, measured
Full `.oss` anim blocks for the 55 real skinned units total **3,247,545 float32
values** — ~12.99 MB binary / ~32 MB as JSON — plus bind verts and weights.
Shipping that is disproportionate. The task explicitly allows a deterministic
subset with exact frame indices recorded, so the exporter keeps a subset of
**real donor frames** only.

### 3.2 Selection rule (deterministic, donor-order)
For every sid, the converter reads that unit's **own** AAF
(`data/animations/aaf/<base>.aaf`, where `<base>` is the manifest mesh basename)
and, for each requested action present, applies the verbatim
`bake_sprites.sample` rule (`first + round((last-first)*i/(N-1))`, `N=6` default):

```
--frames-per-action 6
--actions idle,idle0,walk,walk0,death,attack0,attack1
```

Frames are the union over actions, sorted ascending, with exact donor indices
written to both `<sid>.json:frames` and `index.json:entries[].frames`. If an
action's range is ≤6 frames, all frames are kept (bake_sprites' own rule:
decimating a short walk distorts motion). No interpolation, no tween, no RNG.

### 3.3 What is stored
One `c3_skin_v1` JSON per sid:
`(sid, donor path, AAF path, k, fps, bones, v, actions{first,last,kind,donor,frames},
frames, verts, weights, anim[bone][frame_slot])`, where `anim[bi][fi]` is the
untouched donor bone track at donor frame `frames[fi]`. Floats are trimmed to 6
decimals (≤1e-6 m error). The runtime rebuilds the same packed representation
`parse_donor_oss()` produces and reuses the same skinner; only the anim block is
frame-subsetted. A per-sid `skin_probe_checksum` (flat-root skinned verts at the
first exported frame, computed by the converter's `skin_at()`) is recorded as
donor-grounding evidence; it is not part of the runtime asset path.

### 3.4 Runtime consequences (honest)
- `pose_for`/`play` resolve the inclusive frame from the **unit's own** AAF
  range (falling back to V7-18's peaukr `AAF_ACTIONS` when the unit's AAF lacks
  that action), then snap to the nearest exported donor frame. Ties keep the
  lower frame. `pose["frame"]` is now the **exported donor frame actually used**;
  `pose["requested_frame"]` is the AAF-computed frame. This also dedupes frame
  batches in V7-74's renderer. For legacy/manually registered full skins both
  values remain identical, so V7-64/V7-74 behaviour is unchanged.
- Missing an action in a unit's AAF (e.g. `attack1` for most units) means that
  action is simply absent; no pose is fabricated.

### 3.5 Coverage and skips
62 manifest units were examined; **55 exported**, **7 skipped**, **0 failed**:
`yacht, yachttur, fishboat, frigate, galley, battleship, xebec` all begin with
Donor `IDP2` (`.osm` hulls) and carry no skin tracks — V7-63 already ships them
as static hulls. Skips and reasons are recorded in `index.json:skipped`.

Action coverage across the 55: `idle` 55, `walk` 55, `idle0` 40, `death` 50,
`attack0` 45, `attack1` 13, `walk0` 12. Exported frames per sid: 12–42 (1,452
total). `k` range 133–725.

### 3.6 Size (measured, honest)
| Metric | Bytes |
|---|---:|
| 55 per-sid skin JSON files | **3,712,594** (3.71 MB) |
| `index.json` | 33,944 |
| Total shipped skin directory | **3,746,538** (3.75 MB) |
| Full-anim alternative (not shipped) | ~13 MB binary / ~32 MB JSON |

Conversion is byte-deterministic: two consecutive runs produced the same
`index.json` SHA-256 `FA3A247CA92F6F6E14AE7DC72F94A4BA99505D49D695519CFF87F19F7D589BAA`.
Only JSON text was written; no `.png`, sprite sheet, `index.json` of the 2D
bake, or donor byte copy.

## 4. Exact diff

### `variant3d/scripts/anim3d.gd` (edited; 963 lines, 0 space-indented lines, 0 RNG tokens)

| Final line(s) | Change |
|---|---|
| 35-38 | Header V7-78 auto-load note (converter output, no donor bytes at runtime). |
| 110-124 | `SKIN_INDEX_PATH`, `SKIN_ASSET_DIR`, `SHIPPED_SKIN_SOURCE`, `_shipped_loaded/_count/_bytes/_error`. |
| 136 | `bind()` calls `_ensure_shipped_skins()`. |
| 144, 152-166, 170-171, 191-192 | `play()`: lazy load, per-sid action range, `sample_frame`/`requested_frame`, exact labels kept. |
| 314, 322-348 | `has_skin()` lazy load; `skin_info()` exposes compact/asset/sample_frames/actions/label. |
| 359-369, 376-383 | New `shipped_skin_info()` observability; `capabilities()` reports shipped count/bytes/index. |
| 418-434 | `skin_vertices()` maps donor frame → compact slot via `_nearest_local()` before the unchanged `_qmat`/skin loop. |
| 490-516 | `pose_for()`: lazy load, `_action_range_for()`, per-unit donor cite, sample frame fields. |
| 538-554 | `_morph_fields()` adds `sample_frame` and maps compact skins to the nearest exported frame. |
| 638-643 | `_valid_skin()` accepts `bones*frame_count*7` for compact skins; full skins still `bones*k*7`. |
| 736-935 | New block: `_ensure_shipped_skins()` `:742` (lazy, once, strict index load), `_load_shipped_skin()` `:771` (strict `c3_skin_v1` rebuild, no fill values), `_nearest_local()` `:893`, `_nearest_exported_frame()` `:907`, `_action_range_for()` `:918`. |

All V7-18/V7-64 public signatures (`bind`, `play`, `action_info`, `pose_for`,
`register_skin`, `has_skin`, `unregister_skin`, `skin_info`,
`load_skin_from_donor`, `capabilities`, `parse_donor_oss`, `skin_vertices`,
`sample_frames`) are unchanged. No edit to `world3d_entities.gd`, `world3d.gd`,
`main.gd`, `app/`, config, tests or selftest source; no git operation.

### `variant3d/tools/convert_skins.py` (new)
`read_oss` `:81`, `read_aaf` `:118`, `sample_frames` `:140`, `qmat` `:152`,
`skin_at` `:162`, `r6` `:178`, `convert_unit` `:187`, `main` `:271`.
CLI defaults at `:72-74`; label/cites at `:61-68`.

### `variant3d/assets/models/skin/` (new)
`index.json` + 55 `<sid>.json`. All donor-derived; no binary donor copy.

## 5. Verification — variant3d runner only (job ids + measured results)

Every Godot launch went through `variant3d/tools/godot_runner.py run`; no direct
Godot invocation, no git command.

| Ticket | Job id | Command / purpose | Result |
|---|---|---|---|
| 176 | `v778-anim3d-parse` | `--headless --path variant3d --check-only --script res://scripts/anim3d.gd` | ok, exit 0, run 2.26 s |
| 178 | `v778-auto-skin-probe` | first probe | **timed out** — probe bug (`skin_info` key `verts` read as `v`; `frames1[1]` out of bounds aborted `_initialize()` before `quit`); superseded |
| 180 | `v778-auto-skin-probe2` | corrected probe | ok, exit 0, 21/21 checks PASS |
| **181** | **`v778-auto-skin-probe3`** | final temporary `variant3d/tests/_v778_probe.gd`: real roster sid `peasant`, `world3d_entities.gd` sibling of anim3d, **no skin registration call**, two sync times, plus an independent walk scenario | **ok, exit 0, run 3.13 s, 24/24 checks PASS** |
| 184 | `v778-anim3d-parse-final` | final parse gate | ok, exit 0, run 5.41 s |
| **186** | **`v778-selftest`** | mandated `--headless --path variant3d -- --self-test variant3d/selftest.json` | **ok, exit 0, run 52.39 s; `selftest.json` `passed:true`, 29/29 steps, 0 failed**; stderr only the usual "3 resources still in use at exit" |

### Measured morph with NO manual registration (ticket 181)

| Assertion | Measured |
|---|---|
| Auto-loaded assets | `auto_loaded=55`, `total_bytes=3,712,594`, `error=''` |
| `has_skin("peasant")` with zero registration calls | `true`; `skin_info.source=donor_oss_subset_v1` |
| Shipped header | `k=483, bones=20, verts=577` (V764 §5) |
| Labels | `label=PORT APPROXIMATION — NOT DONOR PARITY`, `visual=UNVERIFIED` |
| Idle scenario, frames | donor `64 -> 74` (idle, from peaukr.aaf:3) |
| Idle rendered buffer | **733 / 733** corners at both frames; **733/733 changed** |
| Idle max / mean delta | **0.022050459 m / 0.007071394 m** (baked Y-up metres) |
| Walk scenario (fresh renderer, `_anim_t=0`), frames | donor `1 -> 9` (9 = nearest shipped frame to computed 10) |
| Walk rendered buffer | **733 / 733** corners; **733/733 changed** |
| Walk max / mean delta | **0.391075552 m / 0.125684882 m** |
| `pose_for("peasant","idle",0.0)` | `pose_source=donor_flat_root_morph`, `frame=64`, `requested_frame=64`, `range=[64,113]`, 577 verts, labels exact |
| Renderer telemetry | `donor_morph_units=1`, `donor_morph_static_units=0`, `donor_morph_rejects={}` |

Independent read-only Python re-implementation of `read_oss` + `skin` + the
V7-74 bbox/Y-up transform gave, for the same donor frames:
`(1,9) max=0.391075624 m mean=0.121683790 m` and
`(1,10) max=0.295301503 m mean=0.103663813 m` over the 577 unique donor verts.
The `(1,10)` max reproduces V7-74's `0.295301526784897 m` and V7-64's
`0.103663814617272 m` mean; the probe's `(1,9)` max matches to 7e-8 m (6-decimal
export rounding). The probe's means are corner-weighted over 733 OBJ corners,
not the 577 unique donor verts, exactly the weighting difference V774 §5 notes.

The probe file and its result JSON were **deleted** after the run (verified:
zero `*v778*` files remain under `variant3d/tests/` or
`variant3d/tests/results/`). `variant3d/selftest.json` was rewritten by the
mandated selftest command itself (generated output, not a source edit).

## 6. Open questions / UNVERIFIED

1. **Visual parity is UNVERIFIED.** Flat-root skin (bone parents unreadable),
   no interpolation between shipped frames, generated normals, donor→Godot
   quaternion convention uncited (`V764 §6 Q4`). A rendered-frame A/B is still
   required before any parity claim.
2. **Subset granularity.** `N=6` per action is a size/coverage compromise
   (3.75 MB shipped). Units whose requested frame is far from a shipped frame
   snap visibly; raising `N` or exporting full anim is a regeneration-only
   change (`--frames-per-action`), with the measured size cost in §3.6.
3. **Per-unit AAF vs V7-18 table.** A shipped skin now overrides the hardcoded
   peaukr ranges. For actions absent from a unit's AAF the legacy peaukr range
   is reused and snapped to the nearest shipped frame — a documented
   approximation, not donor parity.
4. **7 ships skipped** (`.osm`/IDP2, no skin tracks). Hulls remain static —
   consistent with V7-63, but no naval animation is delivered.
5. **Attached tools** are separate donor meshes (`bake_sprites.py:343-353`);
   hand-held tool motion is still not skinned (`V764 §6 Q3`).
6. **Perf.** Auto-load parses 3.75 MB of JSON once on first call (~3 s total
   probe run including Godot startup). Per-unit `pose_for` still skins 577 verts
   / ~584 weight pairs every sync, and frame batches still reserve 4096 slots
   (`V774 §6`); neither was changed here.
7. **One-shot `death` still loops** via `fposmod` (AAF carries no loop flag),
   inherited from `anim3d.gd:582-588` (`V764 §6 Q6`).

## 7. Reply summary

- Files: `variant3d/scripts/anim3d.gd` (edited), `variant3d/tools/convert_skins.py`
  (new), `variant3d/assets/models/skin/` (new, 56 JSON files, 3.75 MB), this
  report. Temporary probe created, run, deleted.
- STATUS: **COMPLETE — shipped donor skins auto-register; rendered morph
  measured with no manual registration; donor parity NOT claimed.**
- Verification: parse ok (176/184), probe 24/24 (181), selftest `passed:true`
  29/29 (186).
- No git operations, no edits to `world3d_entities.gd`, `world3d.gd`, `main.gd`,
  `app/`, config, tests or selftest source. No 2D bake, sprite sheet or RNG.
  Every status keeps `PORT APPROXIMATION — NOT DONOR PARITY`, visual UNVERIFIED.

---

*V7-78, singleplayer-skirmish scope. One owned code file edited, one new
converter, one new donor-derived asset tree and one report; temporary probe
deleted. The shipped runtime now morphs units from real donor-frame skin data
without manual registration — donor-faithful skeletal deformation remains
BLOCKED and the visual result remains UNVERIFIED.*
