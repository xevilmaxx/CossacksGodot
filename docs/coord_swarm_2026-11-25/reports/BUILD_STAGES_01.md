---
id: BUILD-STAGES-01
owner: BUILD-STAGES-01 (implementation builder subagent)
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: DONE__DONOR_STAGE_SELECTOR__NO_STAGE_ART__PARSE_SMOKE_OK
scope: "Implementation builder. Edited ONLY variant3d/scripts/world3d_entities.gd and this report. Donor READ-ONLY: nothing copied, unpacked, executed or edited."
owns:
  - variant3d/scripts/world3d_entities.gd
  - docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md
backup: inbox/backup/world3d_entities.gd.bak-BUILDSTAGES01 (83,751 bytes, taken before first edit)
diff: "+199 / -0 lines (pure insertion) against the backup"
smoke: "variant runner ticket 503, id buildstages01-smoke, status=ok exit=0, stderr 0 bytes -> SCRIPT ERROR == 0"
labels: [DONOR_TRUTH, PORT APPROXIMATION, UNVERIFIED, NO_VISUAL_PARITY]
---

# BUILD-STAGES-01 — donor construction-stage meshes for 3D buildings

> [!IMPORTANT]
> The stage selector follows the donor rule, but **no converted 3D stage or
> scaffold OBJ exists on disk**. Every under-construction building therefore
> reuses its own **base donor mesh**, explicitly labelled **PORT
> APPROXIMATION**. The scaffold node is a structural, **hidden** placeholder.
> No donor byte was copied and no visual-parity claim is made.

## 1. Inputs read before editing

| Input | What was used |
|---|---|
| `reports/DBUILD_01_building_stages.md` | §2.1–2.4 mesh inventory, `floor(progress*4)` mapping, wall `1+stage div 3`, scaffold auto-child, §6 port parity matrix (all four stage rows MISSING). |
| `reports/DBUILD_02.md` | **Not landed** — no file of that name exists anywhere under the root (`Get-ChildItem -Recurse -Filter "*DBUILD_02*"` returned nothing). Nothing assumed from it. |
| `reports/DECOR_01_implementation.md` | Tree pool/scale/jitter contract that must stay byte-identical; 2D bake is explicitly out of scope for this module. |
| `reports/RELIEF_01_stamping.md` | Labelled PORT APPROXIMATION pattern: opt-in donor-derived logic + honest UNVERIFIED labels + variant-runner-only smoke. |
| `reports/MOTION_ANIM_01.md` | Terminated ticket; rotor relocation/fallback and DECOR blocks are frozen and must not change. |
| Owned file `variant3d/scripts/world3d_entities.gd` | Read `add_building()` / `_attach_rotor()` / `bind()` / `sync()` / `remove()` / `_mesh_info()` / `_xf()` in full at the edit seams. |
| Port sim `variant3d/scripts/game.gd:2186-2197`, `:4968-4974` (read-only) | Building entities carry `progress` and `def.build_time`; `spawn()` sets `progress = build_time` when finished. This is the port's 0..1 build counter. |

## 2. Asset availability — measured, not assumed

`variant3d/assets/models/obj/**` contains **172** `.obj` files. All 24 common
building sids (`aca, art, ba2, bar, bla, cen, dip, hou, sta, tem, mar, mil, por,
sga, sto, tow, wal, gat, coa, gol, iro, wga, wwa, bld`) were probed for the
eight donor-named converted suffixes `1, 2, 3, 4, a, 1a, 2a, 3a, 4a`:
**0 hits**. Only **base** meshes exist (`aca.obj`, `art.obj`, `bar.obj`,
`bla.obj`, `cen.obj`, `dip.obj`, `gat.obj`, `hou.obj`, `mar.obj`, `mil.obj`,
`sta.obj`, `sto.obj`, `tow.obj`, `wal.obj`, …).

A separate scan found 2D bake PNGs such as `assets/models/anim/swe/buildings/
swe_cen_s1.png` … `_s4.png`, `_dead.png`. These are the **2D sprite pipeline**,
which this module's charter forbids reading (file header lines 17–20: "NEVER
reads the 2D bake"). They are **not** 3D meshes and were not used.

**Verdict:** the fallback branch of the ticket applies — implement the
donor-cited selector, bind the existing base mesh, report the missing art.

## 3. Donor citations

| Rule implemented | Donor source (via DBUILD-01, read-only) |
|---|---|
| Progress is 0..1 and monotonic; completion selects the base mesh | `scripts/lib/unit.script:6583-6592` |
| `stage = floor(progress * 4)` | `unit.script:6596`; `scripts/units/building.inc/doprogressorders.inc:84-93` (ship dummy, second read) |
| Visual tag 0/1/2/3 → mesh suffix `1/2/3/4` | `scripts/units/building.inc/ontagstates.inc:240-251` |
| Wall special case `stage := 1 + stage div 3` → only mesh 1 or 2 | `ontagstates.inc:247-248`; `commonrus` wall files counted 2/0 in DBUILD-01 §2.4 |
| `progress=1` while unfinished has no `stage_4` case → keep previous mesh | Derived from `unit.script:6594-6603` (DBUILD-01 §2.2 labels this *derived*) |
| Stage-synced scaffold auto-child, meshes `<sid>a` / `<sid><1..4>a`, `scaffold` material | `objects/buildings/engcen.prop:72-112`; `ontagstates.inc:253-259` |
| Port progress counter is `progress / def.build_time` | `game.gd:2193`, `:4968-4974` (port code, read-only) |

## 4. Before → after (line numbers are post-edit)

Backup baseline: `inbox/backup/world3d_entities.gd.bak-BUILDSTAGES01`.
`git diff --no-index --stat` → **199 insertions, 0 deletions**.

| # | Before (backup) | After (live) | Change |
|---|---|---|---|
| 1 | No stage constants | `:248-267` | New `BUILD_STAGE_STEPS=4`, `BUILD_WALL_MAX_STAGE=2`, `BUILD_STAGE_SUFFIXES=["1".."4"]` with donor line citations, plus `BUILD_STAGE_LABEL` / `BUILD_SCAFFOLD_LABEL` PORT APPROXIMATION strings. |
| 2 | No stage mirrors | `:282-284` | New `_build_scaffolds` and `_stage_mesh_cache` dictionaries; cleared in `bind()` at `:350-352`. |
| 3 | `bind()` had no art measurement | `:394-402`, `:464-472` | Measures donor-named stage/scaffold OBJs with `ResourceLoader.exists()` and publishes `build_stage_obj_sids`, `build_scaffold_obj_sids`, `build_stage_art_status`, donor rule strings and UNVERIFIED label. Measured arrays are empty today. |
| 4 | No stage selector | `:1559-1590` | `_build_progress01()` clamps `progress/build_time`; `_build_stage_suffix()` applies donor `floor(p*4)` → suffix 1..4 and wall `1+raw/3` → suffix 1..2, with the derived `stage_4` clamp. |
| 5 | No stage mesh resolver | `:1591-1618` | `_stage_mesh_info()` probes donor-named converted OBJs (`<sid><s>[a].obj`), bakes them through the **existing** `_bake_mesh()` with the base sid bbox, and returns `{}` when art is absent. No asset copy, no new numeric constant. |
| 6 | One static base mesh per building, never changed | `:1620-1700` | `_sync_building_stages()` records stage metadata on the existing parent, swaps `mi.mesh` only when a real stage OBJ resolves, and attaches/removes a stage-synced `Scaffold_<sid>_<id>` child. With no art, stage mesh = base mesh; the scaffold child is hidden (reusing the base mesh would double-render the parent silhouette). |
| 7 | `remove()` dropped `_rotors` only | `:1762-1768` | Drops the scaffold mirror too (guarded by `is_instance_valid`; parent `free()` already frees the child). |
| 8 | Building transform loop flowed straight into MILLFIX rotor block | `:1910-1913` | One call to `_sync_building_stages()` inserted **between** them; the rotor block itself is untouched. |

### Stage → mesh behaviour

| Entity state | Donor rule | Port implementation today |
|---|---|---|
| `finished = true` | base `<sid>.mesh`, scaffold switched to `detail` material | base donor OBJ, no scaffold child |
| `finished = false`, progress `[0,0.25)` | mesh 1 | base OBJ (`PORT APPROXIMATION`), meta `build_stage_suffix="1"` |
| `[0.25,0.5)` | mesh 2 | base OBJ, meta `"2"` |
| `[0.5,0.75)` | mesh 3 | base OBJ, meta `"3"` |
| `[0.75,1.0)` and the derived clamp | mesh 4 | base OBJ, meta `"4"` |
| `sid == "wal"`, raw stage 0/1/2 → mesh 1; raw 3 → mesh 2 | `1+stage div 3` | base OBJ, meta `"1"`/`"2"` |

## 5. Invariants preserved

Direct block comparison against the backup (Python line-slice equality):

- `add_building()` body — **identical**
- `_attach_rotor()` body — **identical**
- `_rotor_material()` incl. the import-cache fallback / white-quad degradation — **identical**
- MILLFIX rotor spin/billboard block in `sync()` — **identical**
- DECOR-01 constant block (`ENV_SCALE` … `TREE_STAND_STATUS`, 60 lines) — **identical**
- Public API signatures `bind(g)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`,
  `add_resource(n)`, `remove(id)` — **identical**. No existing meta key was
  renamed or removed; new `build_stage_*` / `scaffold_*` meta keys are additive.
- No edit to models/assets, other scripts, tests, config or `app/**`; no donor
  asset copied; no gate, ladder or direct `godot` launch.

## 6. Validation — variant runner only

```
python variant3d\tools\godot_runner.py run --id buildstages01-smoke --timeout 120 --max-wait 900 -- \
  --headless --path variant3d --check-only --script res://scripts/world3d_entities.gd
```

| Field | Observed |
|---|---|
| Ticket / id / status / exit | **503** / `buildstages01-smoke` / `ok` / **0** |
| Wait / run | 64.54 s (shared FIFO) / 17.42 s |
| Result | `variant3d/.godot_queue/results/00000503.json`; stdout/stderr in `00000503_buildstages01-smoke/` |
| stderr | **0 bytes → `SCRIPT ERROR == 0`** |
| stdout | only `Godot Engine v4.7.2.stable.official.ed1daf0bf` banner (check-only emits no test output) |

This is a parse/compile check only. It does **not** exercise the stage path at
runtime and makes no rendering or visual claim.

## 7. UNVERIFIED / PORT APPROXIMATION labels

1. **PORT APPROXIMATION** — all construction meshes are the existing base donor
   mesh because no `<sid>1..4.obj` exist; the donor's progressive geometry is
   not reproduced.
2. **PORT APPROXIMATION** — the scaffold child is a hidden structural placeholder
   (base mesh reused with a PORT label), not the donor `<sid>*a` mesh and not
   the donor `scaffold`/`debris` material. Its visibility/material policy is a
   port choice, labelled UNVERIFIED.
3. **UNVERIFIED** — port `progress/build_time` is used in place of donor
   `hp/maxhp`; both are 0..1 build counters, but they are not the same sim
   variable.
4. **UNVERIFIED** — if stage OBJs are added later, they are baked with the
   **base** sid bbox; per-stage bbox/extent is not in `manifest.json`.
5. **UNVERIFIED / derived** — the `progress=1, unfinished` clamp keeps the
   previous stage mesh (donor `case` has no stage_4) — no runtime capture.
6. **UNVERIFIED** — wall identification is port sid `"wal"`; donor wall actors
   are distinguished by `bgate`/`bwall` flags (`ontagstates.inc:247`), which
   this module does not receive.
7. **UNVERIFIED** — death-stage meshes (`_death1/_death2`), death scaffold
   material, and explosion debris are **not** part of this ticket (DBUILD-01 §3
   rows remain MISSING).
8. **UNVERIFIED** — port has no per-nation stage art mapping; the donor 25-nation
   pattern (DBUILD-01 §2.4) cannot be reproduced from 5–14 base sids.

## 8. Open questions

1. Will an asset owner convert donor `<nat><bld>{1..4}.osm` and attach `<sid>*a`
   meshes into `assets/models/obj/**`? The resolver is ready; no name/scale
   change would then be needed here (per-stage bbox still needs a decision).
2. If stage meshes arrive, should the scaffold be **visible** during birth and
   switched to a "detail" mesh at completion, as `ontagstates.inc:92-126,
253-259` do? Current port placeholder is hidden to avoid duplicate silhouette.
3. Should death-stage meshes be a follow-up ticket, and if so, which port event
   supplies the donor 30+30-frame timing (`dmscript.global:183-184`)?
4. Does the port's `finished` flag flip exactly at donor `bbuilt` completion,
   including capture and `bslowdeath` cases? Not measured here.
5. No runtime smoke exists for stage boundaries; a stub probe with controlled
   `progress` values would be needed to assert suffix 1/2/3/4 and wall 1/2.

## 9. Files touched

Edited: `variant3d/scripts/world3d_entities.gd` and this report — **no other
file**. Created the required backup at
`inbox/backup/world3d_entities.gd.bak-BUILDSTAGES01`. The variant runner wrote
its own result artifacts under `variant3d/.godot_queue/results/` (harness
output, not a source edit). Concurrent foreign changes seen in `git status`
were left untouched.

## 10. Summary

Implemented the donor construction-stage **selector** (`floor(progress*4)`,
wall `1+stage div 3`, derived stage-4 clamp) and stage-synced scaffold
attach/remove lifecycle in the owned 3D entity module, with donor line
citations and labelled PORT APPROXIMATION fallbacks. Measured that **zero**
stage/scaffold 3D OBJs exist, so every under-construction building currently
reuses its base donor mesh and carries an honest UNVERIFIED label. Backup taken;
+199/−0 additive lines; variant-runner check-only smoke ticket **503**
`buildstages01-smoke` ok, exit 0, stderr 0 bytes (`SCRIPT ERROR == 0`).
Rotor relocation/fallback, DECOR tree pool/scale and all public APIs are
byte-identical. No donor bytes copied, no other file edited, no visual parity
claim.

*End of BUILD-STAGES-01 report.*
