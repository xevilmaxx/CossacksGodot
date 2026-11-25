---
id: BUILD-ART-C-01
owner: BUILD-ART-C-01 (implementation builder subagent)
role: "Wire the 108 generated stage/scaffold OBJs into the 3D renderer by minimal additive edits to the existing BUILD-STAGES-01 seams"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: IMPLEMENTED__PER_STAGE_BBOX__TINT_REAPPLIED__HONEST_LABELS__SMOKE_AND_64_PROBE_OK__NO_PARITY_CLAIM
scope: "Edited ONLY variant3d/scripts/world3d_entities.gd and this report. Backup written to inbox/backup/world3d_entities.gd.bak-BUILDARTC01. No asset, manifest, test, config, converter, other script, app/** or donor file edited. One temp probe script outside the repo (OS temp folder) wrote no repo file."
owns:
  - variant3d/scripts/world3d_entities.gd
  - docs/coord_swarm_2026-11-25/reports/BUILD_ART_C_01.md
backup: "inbox/backup/world3d_entities.gd.bak-BUILDARTC01 — 103,539 B, SHA-256 4C763ABF580E4299E028AF5F642647785F6E798D05B9D94D6C45E854F2C88951, identical to the live file at copy time"
labels: [observed, derived, UNVERIFIED, NO_VISUAL_PARITY]
parity_claim: none
---

# BUILD-ART-C-01 — runtime integration of the 108 stage/scaffold OBJs

> [!IMPORTANT]
> The selector shipped by `BUILD-STAGES-01` already probed and bound the exact
> donor-named meshes the asset batch produced. This ticket therefore made
> **only three additive seam changes**: (a) per-stage manifest bbox lookup,
> (b) re-application of the player tint after a mesh swap, and (c) honest
> stage labels. No selector, timing, rotor, nation, tree, motion, build-order
> or public-API code was touched. The result is structurally validated,
> **not visually validated**: no donor-vs-port A/B capture exists and
> **no visual, animation or donor parity is claimed**.

## 1. Sources read (read-only this pass)

| # | Path | Use / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGE_INTEGRATION_01.md:1-284` | Live selector contract; plan seams C1 (`:103`), C5 (`:107`), C6–C7 (`:108-109`); frozen-block invariants (`:112-139`); open Q1/Q3/Q4/Q5. **observed** |
| S2 | `docs/coord_swarm_2026-11-25/reports/STAGE_IMPORT_01.md:1-262` | Ticket 534: 108/108 stage `.obj.import` sidecars + generated `.mesh` resources; runtime `load()` and integration were carried forward to C/D (§6). **observed** |
| S3 | `docs/coord_swarm_2026-11-25/reports/BUILD_ART_BATCH_01.md:1-206` | 108 new OBJs/MTNs, 280-entry manifest, 6-number per-stage bboxes, 10 known 8-vert IDP2 donor meshes (§6), hash gates. **observed** |
| S4 | `docs/coord_swarm_2026-11-25/reports/NATION_MODEL_01.md:1-132` | NATION-MODEL-01 terminated; its nation selector / build-order branch are in the owned file and are frozen for this ticket (§3, §7, §11). **observed** |
| S5 | `variant3d/scripts/world3d_entities.gd` | Owned file. Symbols, not stale absolute lines: labels `:283-284`; `bind()` probe `:412-421`; telemetry `:497`; `_apply_tint()` `:984-1001`; `_stage_mesh_info()` `:1793-1815`; `_sync_building_stages()` `:1822-1900`. **observed** |
| S6 | `inbox/backup/world3d_entities.gd.bak-NATIONMODEL01`, `inbox/backup/manifest.json.bak-BUILDARTBATCH` | Pre-edit baselines for the integrity check (§4) and the 172→108 stage set difference (§6). **observed** |
| S7 | `variant3d/assets/models/manifest.json` (read-only) | Verified bboxes `cen1=4`, `cen1a..cen4a`, `cena`, `tow1a`, `mara`; e.g. `cen1 z -0.0507..4.7779`, `cen1a z -0.0797..4.4618`, `cena z -0.0508..-0.0064`. 280 unique sids. **observed** |
| S8 | `docs/variant3d/README.md:129-151`, `variant3d/tools/godot_runner.py` | Runner-only rule; atom `--script` form; absolute temp-script path is accepted (precedent: NATION-MODEL-01 tickets 536/544). **observed** |
| S9 | `variant3d/tests/t_entities3d.gd:13-76` | `extends SceneTree`, `call_deferred("quit", …)` stub-game pattern reused by the temp probe. **observed** |

**Label convention:** **observed** = bytes/files/repo text read this pass;
**derived** = control-flow or arithmetic consequence; **UNVERIFIED** = no
runtime/visual evidence; all parity statements are **NO_VISUAL_PARITY**.

## 2. Donor citations (carried, not re-derived)

| Rule kept by this edit | Donor / plan source |
|---|---|
| `stage = floor(progress*4)` → mesh suffix `1..4` | `unit.script:6596`, `doprogressorders.inc:84-93`, `ontagstates.inc:240-251` (cited in S1 §2 / owned file `:267-282`). **observed** (citation), no selector change |
| Wall fold `1 + stage div 3` → suffix `1..2` | `ontagstates.inc:247-248`; kept `wal`-only. **observed** |
| Stage-synced scaffold auto-child `<sid>a` / `<sid><1..4>a` | `engcen.prop:72-112`, `ontagstates.inc:253-259`; visibility for the under-construction branch already existed. **observed** |
| Completion scaffold `<sid>a` per `ontagstates.inc:112-127` | S1 C4; **not applied** — owner decision Q1 outstanding (§7). **observed** |
| Per-stage bbox authority | `BUILD_ART_01.md:201` item (i), S1 C1; manifest carries 6-number bbox for all 108 new sids (S3/S7). **observed** |
| Tint is donor uniform-0 via alpha-band mask, surface overrides by index | `refunit.mat:37`, `refbuilding.mat:37`, `misc.script:5070`; owned file `_apply_tint():984-1001`. **observed** |

No donor file was opened, copied or executed by this ticket; all donor
citations above are inherited from the plans named in S1/S4.

## 3. Before → after (backup line → live line)

Baseline: `inbox/backup/world3d_entities.gd.bak-BUILDARTC01` (taken before the
first write). Diff vs that backup: **+24 / −11**, exactly **five hunks**.

| # | Before (backup) | After (live) | Change | Label |
|---|---|---|---|---|
| 1 | `:275-279` "No converted stage/scaffold OBJ exists in assets/models/obj/** today …" | `:275-280` | Reworded stale comment: 108 converted OBJs now exist (S2/S3); missing art still PORT APPROXIMATION; visual UNVERIFIED. Comment only. | observed |
| 2 | `:283` `BUILD_STAGE_LABEL` = "no stage OBJ, base donor mesh reused"; `:284` `BUILD_SCAFFOLD_LABEL` = "no scaffold OBJ, structural placeholder only" | `:284`, `:285` | Both constants now state the conditional truth: converted `<sid>1..4` / `<sid>1a..4a` OBJ bound when present (per-stage manifest bbox), base/hidden fallback otherwise; `PORT_LABEL` prefix and `visual UNVERIFIED` retained. | observed |
| 3 | `:497` `build_stage_art_status` = "no stage OBJ, base donor mesh reused" else "stage OBJ present … per-stage bbox UNVERIFIED" | `:498` | Missing-art branch is `PORT_LABEL + BLOCKED …`; art branch reports converted OBJ present and **per-stage manifest bbox applied on swap**; visual stays UNVERIFIED. Parenthesised both ternaries so GDScript precedence is unambiguous. | observed |
| 4 | `:1792` comment "Stage/scaffold use the BASE sid bbox; per-stage bbox is UNVERIFIED"; `:1803` `_bbox.get(sid, [])`; `:1813` "base sid bbox reused … UNVERIFIED" | `:1793-1820` | `art_sid = sid + suffix + ("a" if scaffold else "")` (`suffix==""` + scaffold gives `<sid>a`); `bbox = _bbox.get(art_sid, _bbox.get(sid, []))`; added `bbox_sid` and rewrote `bbox_note`. Path expression, `scale=1.0`, `_bake_mesh()` call, `{}` fallback and `_stage_mesh_cache` are **unchanged**. | derived from S1 C1 |
| 5 | `:1853-1854` bare mesh swap | `:1859-1867` | On every *real* mesh change, derive `tint = _player_tint(_player_index(e))` and, if `Color`, call `_apply_tint(mi, chosen, tint, sid, "building")`. Base `sid` is passed so the existing donor band mask is used; no new tint policy. Runs both into stage art and back to the base mesh at completion. | derived from S1 C5 |

Everything else in the file is byte-identical to the backup (§4).

## 4. Backup and frozen-block integrity

- Backup created **before the first edit** with
  `Copy-Item -LiteralPath "variant3d\scripts\world3d_entities.gd" -Destination "inbox\backup\world3d_entities.gd.bak-BUILDARTC01" -Force`.
  Size **103,539 B**; SHA-256 `4C763ABF580E4299E028AF5F642647785F6E798D05B9D94D6C45E854F2C88951`
  matched the live file at copy time. **observed**
- `git diff --no-index backup live`: exactly the five hunks in §3 (**+24/−11**).
  `git diff --no-index … | Select-String '^@@'` → `@@ -272`, `-494`, `-1789`,
  `-1810`, `-1852`. **observed**
- Function-slice comparison of **24** protected symbols (code lines only,
  comments excluded) reported **0 differences**: `_attach_rotor`,
  `_rotor_mesh`, `_rotor_material`, `_build_progress01`, `_build_stage_suffix`,
  `_resource_sid`, `_pick_sid`, `add_resource`, `remove`, `sync`, `_unit_action`,
  `_entity_mesh_sid`, `_record_nation_mesh`, `_nation_of`,
  `_donor_building_prefix`, `_nation_mesh_on_disk`, `_player_index`,
  `_player_tint`, `_apply_tint`, `_bake_mesh`, `_mesh_info`, `add_unit`,
  `add_building`, `_measure_band`. Public API signatures `bind(g)`, `sync(dt)`,
  `add_unit(e)`, `add_building(e)`, `add_resource(n)`, `remove(id)` are
  unchanged; the stage call still precedes the MILLFIX rotor block. **observed**
- **Concurrent-commit observation:** during validation a foreign `step` commit
  (`65a1f49a`) captured this exact 35-line diff and the backup into `HEAD`, so
  `git status` is now clean for the owned file. I performed **no** `git add`,
  `commit`, `checkout`, `stage`, `cancel`, `doctor`, `ack`, `reset` or
  `unwedge`. Other owners' concurrent edits were left untouched. **observed**

## 5. Validation (variant runner only; no direct `godot`)

All launches went through `python variant3d\tools\godot_runner.py run`; each id
was submitted **once**, never re-submitted; the queue was not mutated.

| Ticket | id | argv | wait / run | status / exit | stdout / stderr | `SCRIPT ERROR` |
|---:|---|---|---|---|---|---|
| 552 | `buildartc01-smoke` | `--headless --path variant3d --check-only --script res://scripts/world3d_entities.gd` | 0.00 s / 17.37 s | **ok / 0** | 75 B banner / **0 B** | **0** |
| 553 | `buildartc01-probe` | `--headless --path variant3d --script C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/buildartc01_probe.gd` | 0.00 s / 17.14 s | **ok / 0** | banner + 14 `PROBE PASS` lines + 1 `PROBE_DONE` / **483 B** | **0** |

Probe stderr honesty: the 483 B is **one pre-existing `push_warning`** from
`bind()` (`ANIM_STATUS`, `world3d_entities.gd:519`) with a GDScript backtrace —
**not** an error and not attributable to this edit. No `SCRIPT ERROR` line
exists in either job's stdout or stderr. The smoke job has **0 B** stderr.

Probe configuration: `extends SceneTree`, 64×64 `StubGame` (`MAP_W=MAP_H=64`,
`players[0].nation="ukr"`), `call_deferred("quit", code)`, script stored only in
OS temp (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`); no repo test,
fixture, result JSON or config was written.

Verbatim probe results (14/14 checks PASS, `PROBE_DONE fails=0 code=0`):

- `bind_stage_sids` → `stage_obj_sids=12` (the 12 art-bearing non-wall sids).
- `bind_scaffold_sids` → `scaffold_obj_sids=61` (see §9 Q2).
- `art_status_honest` → status string no longer contains "no stage OBJ".
- `all_manifest_meshes_load` → **loaded=280 / failed=0**. This closes the
  runtime `load()`-as-`Mesh` half of the batch gate for **all 108 new stage /
  scaffold meshes**, which `STAGE_IMPORT_01.md` and `QA_BUILD_ART_01.md` had
  left UNVERIFIED. It is a structural load proof, **not** a render proof.
- `building_node` → `Building_cen_1_STATIC_POSE:<MeshInstance3D>`.
- `stage_source` → `obj_stage_zup_bbox_normalised`; `stage_suffix_2` → `"2"`
  (progress 25 / build_time 100 = 0.25 → `floor(0.25*4)=1` → suffix `"2"`).
- `tint_reapplied` → a `ShaderMaterial` surface override reappeared after
  being explicitly cleared before `sync()`; the new re-apply seam is exercised.
- `scaffold_child` / `scaffold_visible` / `scaffold_source` → found, `true`,
  `stage_scaffold_obj`; `scaffold_mesh_surfaces=1`.
- `per_stage_bbox_sid` → `bbox_sid=cen2`, `note=per-stage manifest bbox`.
- `stage_hits` → `build_stage_obj_hits=1`.

**Validation verdict:** final code parse smoke and 64² runtime probe both
`status=ok`, `exit=0`, `SCRIPT ERROR == 0`. `--check-only` executes no test;
the probe exercises the owned stage path only. **No pixel, donor or visual
assertion was made.**

## 6. Which stage families resolve vs remain degenerate

Measured from the manifest + OBJ vertex counts (read-only, S3/S7):

| Family | Count | Under-construction result |
|---|---:|---|
| Parent digit stages `<sid>1..4` (12 art sids × 4) | 48 | **Resolve**: `cen1..cen4`, `hou1..4`, `bar1..4`, `sta1..4`, `bla1..4`, `aca1..4`, `art1..4`, `dip1..4`, `sto1..4`, `mil1..4`, `mar1..4`, `tow1..4` all load and bind with their **own** manifest bbox. Probe confirmed `cen2`. |
| Stage scaffolds `<sid>1a..4a` | 48 | **Resolve**: bind to the scaffold child, which becomes visible (`stage_scaffold_obj`). Probe confirmed `cen2a`. |
| Base scaffolds `<sid>a` | 12 | On disk and load; 10 of them are the known **degenerate 8-vert / 12-face IDP2** meshes: `cena`, `houa`, `bara`, `staa`, `blaa`, `acaa`, `arta`, `dipa`, `mara`, `tow1a`. They are valid donor-derived data but their visual role is **UNVERIFIED** (S3 §6 / S1 R3). `tow2a/tow3a/tow4a/towa` are non-degenerate. |
| `wal`, `gat` | 0 stage art | **BLOCKED**: no stage/scaffold OBJ; selector keeps the base-mesh approximation. `wal` folds to suffix `1/2`; `gat` keeps 4 stages (Q4 unresolved). No art was fabricated. |
| Death stages `_death1/_death2`, `debris` | 0 | Out of scope in all tickets; still absent. |
| Nation-prefixed 3D art (`rus*`, `bav*`, `eur*`) | 0 | Still BLOCKED per NATION-MODEL-01 §4; this ticket did not create any. |

Degenerate cases are **not** hidden by the new labels: the art-status string
stays `PORT APPROXIMATION … visual UNVERIFIED` and the missing-art branch is
explicitly `BLOCKED`. Because the completion branch is unchanged (§7), the
10 minimal `<sid>a` meshes are not newly rendered by this ticket; their
silhouette question remains open.

## 7. Explicitly NOT done (out of this grant)

- **S1 C4 — completion scaffold** (`<sid>a` kept/visible at `finished=true`,
  donor `ontagstates.inc:112-127`): **not applied**. The owned completion
  branch still frees/erases the child. This is an owner decision (Q1) and was
  outside the three enumerated items of this ticket. No behaviour flip.
- **S1 C6 — fuller availability telemetry**: the existing probe still tests
  only `<sid>1.obj` and `<sid>a.obj`; the 61-vs-12 scaffold-sid count (§9 Q2)
  is therefore not corrected here. No stats key was added or removed.
- **`gat` wall rule** (Q4): unchanged, still `wal`-only.
- No stage constant, `BUILD_STAGE_STEPS`, suffix string, progress formula,
  timing, scaffold `cast_shadow` setting, death-stage handling, rotor, nation
  selector, build-order action, tree pool or motion code was changed.
- No test was created, weakened, skipped or re-run as a substitute; atom D is
  still outstanding (§8).

## 8. Remaining atom — BUILD-ART-D

`BUILD-ART-D` (isolated 64² atom, new `variant3d/tests/t_build_stages.gd` +
result JSON) remains **outstanding**. It must assert the five progress points
(`cen1/cen2/cen3/cen4` + derived stage-4 clamp), completion path, wall fold,
visible stage scaffold, `bbox_sid`, positive `build_stage_obj_hits` /
`build_scaffold_obj_hits`, and exit 0 / stderr 0 B / `SCRIPT ERROR == 0`,
atom-only, never merged with the integrated `selftest.json`. This ticket
submitted a **temporary external probe**, not that atom, and makes **no test
claim** on its behalf. No parity claim is made here.

## 9. Open questions

1. **Q1** — Accept S1 C4 (visible `<sid>a` at completion) or keep the current
   freed-child path with the PORT APPROXIMATION label? Still an owner decision;
   not changed here.
2. **Q2** — `bind_scaffold_obj_sids` measured **61**, not 12: 49 stage-parent
   sids (`cen1..tow4`) also satisfy the existing `<sid>+"a.obj"` probe because
   `<sid>1a..4a` files are themselves manifest sids. The array is therefore a
   superset of the 12 base scaffolds. It is a pre-existing probe shape; left
   unchanged to honour the "stats keys unchanged" constraint. Owner of C6 may
   narrow it.
3. **Q3** — Are the 10 minimal 8-vert donor meshes intentional LOD or empty
   placeholders? Vertex counts cannot answer; a render test is still needed.
4. **Q4** — Fold `gat` into stages `1..2` like `wal`, or keep the current
   `wal`-only rule? Unchanged here.
5. **Q5** — Tint uses the **base** sid for `_measure_band()`; the stage sid
   (`cen2`) has no donor band-mask entry. Is a stage-specific mask ever
   desirable? No such art exists, so none was invented.
6. **Q6** — Scaffold material: imported `scaffold.png` MTL vs explicit port
   material remains UNVERIFIED (donor shader/blend is engine-side).
7. **Q7** — Runtime probe closed `load()`-as-`Mesh` for 280/280; visual A/B
   capture and a donor-vs-port comparison remain the only way to close visual
   parity.
8. **Q8** — A foreign `step` commit captured the diff and backup into `HEAD`
   during validation (§4); no git operation was performed by this ticket.

## 10. No-parity claim

**No visual, animation or donor parity is claimed.** The donor was not read,
rendered or copied by this ticket. Meshes were only `load()`-ed as resources
and swapped by existing selector code in a headless 64² stub probe; no image
was captured and no A/B comparison exists. Every changed label keeps
`PORT APPROXIMATION` and `visual UNVERIFIED`. Per
`WAVE7_3D_VARIANT_CHARTER.md:29-38`, all stage art remains a static bind-pose
**PORT APPROXIMATION** until an A/B capture exists.

## 11. Summary

- **Donor-grounded, minimal:** five additive hunks (+24/−11) at the
  BUILD-STAGES-01 seams only: stale comment honesty, two label constants, one
  telemetry status string, per-stage manifest bbox with base fallback, and
  tint re-application on real mesh swaps.
- **Before → after:** `:275-279→:275-280`, `:283-284→:284-285`,
  `:497→:498`, `:1792/:1803/:1813→:1793-1820`, `:1853-1854→:1859-1867`.
- **Backup:** `inbox/backup/world3d_entities.gd.bak-BUILDARTC01`, 103,539 B,
  SHA-256 `4C763ABF…C88951`, taken before first edit.
- **Jobs:** `buildartc01-smoke` (552) `ok` / exit 0 / stderr **0 B** /
  `SCRIPT ERROR == 0`; `buildartc01-probe` (553) `ok` / exit 0 /
  `SCRIPT ERROR == 0`, 14/14 probe checks PASS (`fails=0`), 280/280 manifest
  meshes load as `Mesh`, probe stderr 483 B of pre-existing `ANIM_STATUS`
  warning only.
- **Resolution:** 48 parent stage + 48 stage-scaffold meshes resolve with real
  art and their own bboxes; 12 base scaffolds exist, 10 of them degenerate
  8-vert donor cases (visual role UNVERIFIED); `wal`/`gat` and death stages
  stay BLOCKED / out of scope.
- **No parity claim. Atom D remains outstanding.** Completion scaffold (C4),
  fuller telemetry probe (C6) and `gat` fold (Q4) were deliberately not
  changed.
- **Scope:** no file other than `variant3d/scripts/world3d_entities.gd` and
  this report was edited by this ticket. The only additional file written was
  the backup (required by the task) and a temp probe script outside the repo;
  no asset, manifest, test, config, converter, other script or `app/**` file
  was touched.

*End of BUILD-ART-C-01 report.*
