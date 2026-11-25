---
id: BUILD-STAGE-INTEGRATION-01
owner: BUILD-STAGE-INTEGRATION-01 (read-only planning worker)
role: "Plan the runtime hookup of the generated stage/scaffold OBJs; plan only, no implementation"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: PLAN_ONLY — NO_CODE_EDITS — NO_RUNNER_JOBS — NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/BUILD_STAGE_INTEGRATION_01.md (exclusive output path)"
scope: "Read-only inspection of variant3d/scripts/world3d_entities.gd, assets and reports. The owned file is concurrently owned by NATION-MODEL-01 (running); patch by symbol, never by absolute line."
labels: [observed, derived, inferred, UNVERIFIED, NO_VISUAL_PARITY]
---

# BUILD-STAGE-INTEGRATION-01 — plan: runtime hookup of generated stage/scaffold OBJs

> [!IMPORTANT]
> This is a **plan only**. No source file, asset, manifest, test or config was
> edited; no Godot runner job was submitted. The generated art is **on disk**,
> but `BUILD_ART_BATCH_01.md` has **not landed**, so its own hash/count gates
> could not be read. Every parity statement stays **UNVERIFIED** until a
> donor-vs-port visual A/B capture exists.

## 1. Sources (all read-only this pass)

| # | Path | Use / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md:1-191` | Live selector contract: `floor(progress*4)`, wall fold, derived stage-4 clamp, hidden scaffold placeholder, original **0 stage OBJ** measurement, 8 UNVERIFIED labels, frozen-block inventory. **observed** |
| S2 | `docs/coord_swarm_2026-11-25/reports/BUILD_ART_01.md:1-297` | Authoritative ordered plan; ticket (c) integration at `:201`, ticket (d) 64² atom at `:202`, risks R1–R13, open questions Q1–Q8. **observed** |
| S3 | `docs/coord_swarm_2026-11-25/reports/BUILD_ART_CONV_01.md:1-195` | Converter landed: `stage_models()` 108 entries, `--include-stages` opt-in, unique sids, `tex_name` policy. **observed** |
| S4 | `variant3d/scripts/world3d_entities.gd` | Owner file (co-owned with NATION-MODEL-01). Stage constants `:265-283`; mirrors `:299-301`; `bind()` clears `:367-370`, manifest read `:380-394`, availability probe `:411-420`, telemetry `:487-495`; `_entity_mesh_sid()` `:695`; `_apply_tint()` `:947-964`; `_bake_mesh()` `:993-1046`; `_mesh_info()` `:1049`; `add_building()` `:1584-1625`; selector `_build_progress01()` `:1729-1738`, `_build_stage_suffix()` `:1744-1750`; resolver `_stage_mesh_info()` `:1756-1778`; lifecycle `_sync_building_stages()` `:1785-1863`; `remove()` `:1926-1933`; call site `:2075-2078`; rotor block `:2080-2115`. **observed** |
| S5 | `variant3d/assets/models/manifest.json` (280 models) | Live stage entries `cen1..cen4`, `cen1a..cen4a`, `cena`, … `tow4a`, `towa` — 108 unique new sids; per-stage 6-number bboxes present. **observed** |
| S6 | `inbox/backup/manifest.json.bak-BUILDARTBATCH` (172 models) | Pre-batch baseline: 172 → 280, **0** base-sid bbox mismatches, 108 new sids. **observed** |
| S7 | `variant3d/assets/models/obj/**` (280 `.obj`) | 172 base + 108 new; probe vertex counts `cen1=1702`, `cen1a=4293`, `cena=8`, `tow1a=8`, `mara=8`. **observed** |
| S8 | `variant3d/assets/models/tex/scaffold.png` | Present. **observed** |
| S9 | `variant3d/tests/t_entities3d.gd:13-76` | Atom pattern: `extends SceneTree`, self-exit via `call_deferred("quit", …)`, stub game with `map_w=map_h=64`, result JSON with `passed`/`checks`. **observed** |
| S10 | `git status --short` | `world3d_entities.gd` and `manifest.json` modified by others; `BUILD_ART_BATCH_01.md` absent. **observed** |

**Label convention** (from S2 §1.4): **observed** = bytes/files/repo text read this pass;
**derived** = arithmetic or control-flow consequence of observations;
**inferred** = strong but indirect synthesis; **UNVERIFIED** = no readable
evidence and no runtime/visual capture.

Line numbers marked **observed** are from the current worktree. S2 cites the
stage block at `:1559-1699` / call site `:1913`; those are **stale** because
NATION-MODEL-01 inserted ~165 lines before it. The live equivalents are
`:1724-1863` / `:2078` (S4). **observed** doc drift; all patches below are
specified by function/symbol, not by absolute line.

## 2. Observed state before integration

### 2.1 The asset batch landed; its report did not

- `BUILD_ART_BATCH_01.md` exists **nowhere** under the root; only
  `inbox/backup/manifest.json.bak-BUILDARTBATCH` exists. The batch ticket's own
  gates (SHA-256 identity of the 172 base assets, full `load()` of all 108 new
  meshes, no donor-extension file in the repo) are therefore **UNVERIFIED** as
  *reported* gates. **observed** (absence), **UNVERIFIED** (gates).
- Independently measured this pass: manifest **280** entries vs backup **172**;
  **108** new sids; **0** base-sid bbox mismatches; OBJ count **280**; stage/scaffold
  names **96** (`<sid>1..4` + `<sid>1a..4a` for 12 sids) plus **12** base
  scaffolds (`<sid>a`) = **108** new OBJs; `scaffold.png` present. **observed**
- Twelve art-bearing sids, all non-wall: `cen, hou, bar, sta, bla, aca, art,
  dip, sto, mil, mar, tow`. `wal` and `gat` have **no** stage art. **observed**
- Five known 8-vertex minimal meshes among the new set (`cena`, `tow1a`,
  `mara`, plus the other Ukrainian base scaffolds / `eurtow1a` class from
  S3 §2). They are valid IDP2-derived geometry but visually degenerate;
  **UNVERIFIED** whether intentional LOD. **observed** (vert counts) /
  **UNVERIFIED** (visual role).

### 2.2 The runtime selector is already art-ready

`BUILD_STAGES_01` shipped the donor selector and a resolver that probes exactly
the names the batch produced:

- `_build_progress01():1729-1738` → `clampf(progress / def.build_time, 0, 1)`,
  `finished=true` forces `1.0`.
- `_build_stage_suffix():1744-1750` → `raw = floor(p*4)` clamped 0..3,
  `mesh_stage = raw+1`; wall special case `mini(1 + raw/3, 2)` for `sid=="wal"`
  at `:1748-1749`.
- `_stage_mesh_info():1756-1778` → path `OBJ_DIR + sid + suffix +
  ("a.obj" if scaffold else ".obj")` at `:1762`. With `suffix=""` and
  `scaffold=true` this already yields `<sid>a.obj`, so the completion scaffold
  needs **no new path logic**. **derived**
- `_sync_building_stages():1785-1863` already swaps `mi.mesh` to a resolved
  stage mesh at `:1808-1817` and sets `scaffold.visible = sc_art` at `:1853`.
  Once art resolves, real stage/scaffold meshes bind **automatically**. **derived**

Consequence: the minimal integration is **not** a new selector; it is (a) read
the per-stage bbox, (b) change the completion branch from *free* to *keep and
bind `<sid>a`*, (c) re-apply tint after the mesh swap, and (d) fix the telemetry
labels. **derived**

## 3. Integration plan — exact minimal change in the owner file

Owner: `variant3d/scripts/world3d_entities.gd` **and this report only**.
Restrict all edits to the existing BUILD-STAGES-01 seams listed in S4; do NOT
touch NATION-MODEL-01's inserted region (`:1552-1558`, `:1593-1599`,
`:695-739`). Coordinate with NATION-MODEL-01 before any edit: the file is
currently in its ownership window (S10; S2/S3 warn of this). **observed**

| # | Seam (current line) | Minimal change | Behaviour after change | Label |
|---|---|---|---|---|
| C1 | `_stage_mesh_info()` `:1756-1778`, bbox lookup `:1766` | Compute `art_sid = sid + suffix + ("a" if scaffold else "")`; special-case `suffix=="" && scaffold` → `sid+"a"`. Use `_bbox.get(art_sid, _bbox.get(sid, []))`. Keep `scale=1.0` and the existing `_bake_mesh()` call at `:1772` unchanged; update `bbox_note` at `:1776` and add `bbox_sid`. Keep `{}` fallback at `:1761` and `_stage_mesh_cache` at `:1757-1760,1777`. | Each `<sid>1..4[ a]` mesh is centred with **its own** manifest bbox instead of the base bbox; the earlier "per-stage bbox UNVERIFIED" note becomes measured. No new numeric constant. | derived |
| C2 | `_sync_building_stages()` stage branch `:1806-1824` | **No selection change.** `_build_stage_suffix()` `:1744-1750` remains the single chooser of `sid1..4`; `_stage_mesh_info(sid, suffix, false)` `:1808` resolves `sid1.obj..sid4.obj`. Keep `source` labels at `:1811,1814`. | At progress 0/.25/.5/.75 the parent binds `cen1/cen2/cen3/cen4` (baked) for art-bearing sids; sids without art keep `base_mesh_port_approximation`. | observed + derived |
| C3 | `_sync_building_stages()` scaffold creation `:1832-1842`, resolution `:1843-1855` | **No path/visibility change for under-construction buildings.** `_stage_mesh_info(sid, suffix, true)` `:1843` resolves `sid1a.obj..sid4a.obj`; `sc_art` `:1844` becomes true, so `(sc as MeshInstance3D).visible = sc_art` at `:1853` turns the child visibly on for art-bearing sids. Keep `cast_shadow = OFF` at `:1839` and the `scaffold_source` meta values at `:1854-1855` (`"stage_scaffold_obj"` now becomes the true branch). | Scaffold child visible with stage scaffold mesh; still attached/removed with the parent. Sids without art remain hidden placeholders with the honest fallback label. | derived |
| C4 | `_sync_building_stages()` completion branch `:1827-1830` | Replace unconditional `free()`/`erase()` with: resolve `_stage_mesh_info(sid, "", true)` → `<sid>a.obj`; if a Mesh resolves, **keep** the child, set its mesh, `visible=true`, `scaffold_source="base_scaffold_obj"`, and keep `_build_scaffolds[id]`; otherwise keep the current free/erase path with the PORT APPROXIMATION label. Mirror donor `ontagstates.inc:112-127,253-259` (S3 §2). This is S2 open question 1 / S2–S3 Q1 — an owner decision to confirm, not a silent behaviour flip. | Completed `cen` shows `cena.obj`; completed art-less `wal`/`gat` keeps today's freed-child path. No death-stage or `debris` handling. | derived (donor citations observed; completion visual UNVERIFIED) |
| C5 | `_sync_building_stages()` swap at `:1816-1817` | When `chosen != base_mesh`, re-apply the player tint: derive `tint` from `_player_index(e)` and call `_apply_tint(mi, chosen, tint, sid, "building")`, or assert `chosen.get_surface_count() == base_mesh.get_surface_count()` and document the equality. `_apply_tint():960-964` writes **surface overrides by index**; a stage mesh with a different surface count otherwise drops tint. **Alternative** (owner choice Q5) is to pass stage art sid `sid+suffix` so `_measure_band()` uses the stage manifest texture path. | Player colour survives a stage swap; no new tint policy invented. | derived; visual effect UNVERIFIED |
| C6 | `bind()` availability probe `:411-420` | Extend the probe to also test `OBJ_DIR + s + "1a.obj"` (and optionally all `1..4`/`1a..4a`) so `stats.build_stage_obj_sids` / `build_scaffold_obj_sids` at `:493-494` actually measure the new art. Keep the existing key names and the loop shape. | Telemetry stops under-counting art; `build_stage_obj_hits` / `build_scaffold_obj_hits` at `:1859,1861` become positive on real runs. | derived |
| C7 | Labels `:282-283`, telemetry `:488-495`, `:1862-1863` | Reword the unconditional "no stage OBJ, base donor mesh reused" strings in `BUILD_STAGE_LABEL`, `BUILD_SCAFFOLD_LABEL` and `build_stage_art_status` so they report measured art where present and PORT APPROXIMATION elsewhere. Keep `PORT_LABEL` prefix, `"UNVERIFIED"` visual value, and the rule strings at `:490-491`. **No parity claim.** | Honest labels; no silent overclaim. | derived |
| C8 | `gat` wall rule `_build_stage_suffix():1748-1749` | **Leave unchanged** (`wal` only). `gat` has no art, so it stays base-mesh approximation; document as Q4 rather than changing behaviour. | No un-gated semantic change. | inferred |

### What stays byte-identical (hard invariants)

Assert by line-slice comparison against the pre-integration copy of the file
(the correct baseline is the **NATION-MODEL-01 current** file, not the older
`world3d_entities.gd.bak-BUILDSTAGES01`, because of S4 drift):

1. `add_building()` body `:1584-1625`, including the mill-only
   `_attach_rotor(id, mi)` at `:1624-1625`. **observed**
2. `_attach_rotor()` `:1704-1721`, `_rotor_mesh()` `:1636-1661`, and
   `_rotor_material()` `:1664-1701` including the import-cache fallback /
   white-quad degradation at `:1676-1697`. **observed**
3. MILLFIX rotor spin/billboard block in `sync()` `:2080-2115` — the stage call
   stays at `:2078`, **before** it. **observed**
4. DECOR-01 constant block and tree pool: `_resource_sid()` `:1866-1880`,
   `_pick_sid()` `:1884-1888`, `add_resource()` `:1891-1909` and the tree
   constants (`POOL_TREE` etc.) — untouched. **observed**
5. Build-order action handling (`_unit_action()` build/repair → `construct`,
   owned by NATION-MODEL-01 per `BUILD_ANIM_01.md:107`) — untouched. **observed**
6. Motion block (`_motion_sample`, `_face_smooth`, `_applied_pose_frame`,
   `motion_*` telemetry) and nation helpers (`_entity_mesh_sid():695`,
   `_record_nation_mesh` call sites `:1558,1598`) — untouched. **observed**
7. Public API signatures `bind(g)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`,
   `add_resource(n)`, `remove(id)`; `remove()` scaffold mirror cleanup
   `:1929-1933` survives (child freed only if still valid). **observed**
8. No donor file read at runtime, no asset/OBJ/MTL/PNG edit, no new numeric
   constant, no manifest edit, no test/config/`app/**` edit. **observed** (plan
   constraint)

### Ordering and gates before merging C1–C7

- **Do not integrate before the asset batch report lands and its gates pass**:
  verify SHA-256 of the 172 pre-existing assets against
  `manifest.json.bak-BUILDARTBATCH`, 280 manifest entries, `load()` non-null as
  `Mesh` for all 108 new OBJs, and zero donor extensions in the repo. Only the
  manifest-side checks are re-measurable today (S5/S6); the hash/load gates are
  **UNVERIFIED** (S2 ticket b, S3 §5).
- Then apply C1–C7, re-run the parse-only runner smoke: exit 0, stderr 0 bytes,
  `SCRIPT ERROR == 0` (pattern from S1 §6).
- Then run the §4 atom. Atom-only: never merge with the currently red
  integrated `variant3d/selftest.json`. **observed** (S2 R10)

## 4. 64² runtime assertion spec (ticket d)

New isolated atom `variant3d/tests/t_build_stages.gd` (+ `.uid`), result
`variant3d/tests/results/t_build_stages.json`; fixture
`variant3d/tests/fixtures/small_map_64.json` (`map_w=map_h=64`, seed
`20261113`, `render_mode=3d`). Pattern from S9: `extends SceneTree`,
`call_deferred("quit", code)`, stub game with `map_w=map_h=64`, write JSON with
`passed`, `checks`, `internal_errors`. Submit via
`variant3d/tools/godot_runner.py`; the exact `--script`/`--config` flags are
**UNVERIFIED** until execution (S2 Q8) — the gate is result JSON + exit/stderr.

### 4.1 Progress → expected mesh table (the five required points)

Drive `progress = p * build_time` with `build_time = 100` so the runtime
computes exactly `p` (`_build_progress01():1732-1738`). Use `cen` for the
art-bearing path; `finished=false` unless stated.

| Input p | `raw = floor(p*4)` | `build_stage_suffix` | parent mesh expected | scaffold child expected | Label |
|---:|---:|---|---|---|---|
| **0.00** | 0 | `"1"` | `cen1.obj` → baked `cen1` | visible, `cen1a.obj` | observed rule + derived values; visual UNVERIFIED |
| **0.25** | 1 | `"2"` | `cen2.obj` | visible, `cen2a.obj` | derived |
| **0.50** | 2 | `"3"` | `cen3.obj` | visible, `cen3a.obj` | derived |
| **0.75** | 3 | `"4"` | `cen4.obj` | visible, `cen4a.obj` | derived |
| **1.00**, `finished=false` | 3 (clamped) | `"4"` | `cen4.obj` (derived stage-4 clamp, no donor `stage_4`) | visible, `cen4a.obj` | derived + UNVERIFIED edge |
| **1.00**, `finished=true` | — | `"finished"` | **base** `cen.obj` | completed base scaffold `cena.obj`, visible (after C4); if owner keeps free path, no child + PORT APPROXIMATION | donor citations observed; port behaviour UNVERIFIED until C4 decision |

All five boundary multipliers are exact binary values (`0.25*4 == 1`,
`0.75*4 == 3`), so no float-tolerance ambiguity at the stated points. Add
guard points `p=0.2499 → "1"`, `p=0.4999 → "2"`, `p=0.7499 → "3"` to catch an
off-by-one (`ceil`/round) regression. **derived**

Wall/gate controls: add `wal` at p=0.0 and p=0.9 → suffix `"1"` and `"2"`
(wall fold at `:1748-1749`); assert **base-mesh approximation** and **no**
stage/scaffold art claim, since `wal`/`gat` have no converted meshes. **derived**

### 4.2 Assertion checklist (JSON `checks` rows)

1. For each art-bearing p row: `mi.get_meta("build_stage_suffix")` equals the
   table value; `mi.get_meta("build_stage_progress01")` equals p within 1e-6.
2. `mi.get_meta("build_stage_source") == "obj_stage_zup_bbox_normalised"` for
   `cen1..cen4` (not `"base_mesh_port_approximation"`).
3. Structural mesh proof: the assigned mesh has `get_surface_count() > 0`,
   finite AABB and the same vertex count as the corresponding raw OBJ
   (`cen1=1702`, `cen1a=4293`). Do **not** assert pointer identity with
   `load("res://…/cen1.obj")`: `_bake_mesh():1005,1040-1046` returns a **new**
   `ArrayMesh`. **derived from observed code**
4. Scaffold child named `Scaffold_cen_<id>` exists; `visible == true`;
   `scaffold_source == "stage_scaffold_obj"`; its mesh vertex count matches
   `cen1a..cen4a`.
5. Completion: parent mesh is the base `cen` mesh; with C4 accepted, child
   exists, `visible == true`, `scaffold_source == "base_scaffold_obj"`, mesh
   vertex count matches `cena` (note: `cena` is an 8-vert minimal mesh — assert
   presence, not visual quality). With C4 rejected, child is absent and
   `scaffold_source` reports the PORT APPROXIMATION fallback.
6. Per-stage bbox: `_bbox` contains `cen1..cen4`, `cen1a..cen4a`, `cena`, and
   the base `cen` bbox is byte-equal to the backup manifest value (S6).
7. Telemetry: `stats.build_stage_obj_hits >= 4`,
   `stats.build_scaffold_obj_hits >= 4`,
   `stats.build_stage_approx_nodes` counts only art-less sids, and no label
   string contains the unconditional "no stage OBJ" claim.
8. Frozen-block invariants from §3: a source line-slice check (or explicit
   report row) confirming rotor, DECOR tree pool, build-order action, motion and
   nation blocks are unchanged.
9. Harness gate: ticket status `ok`, exit `0`, stderr **0 bytes**,
   `SCRIPT ERROR == 0`, JSON `passed: true`.

**No test weakening.** Do not convert a failed assertion into a warning, do not
skip p rows because a mesh is 8-vert, do not lower the `>=4` thresholds, and do
not substitute a static source scan for the runtime mesh assertions. The atom
is **atom-only** and makes **no pixel/visual assertion**.

## 5. Risks

| # | Risk | Label | Mitigation / gate |
|---|---|---|---|
| R1 | Batch report missing → its SHA-256 and `load()` gates are unread, so the 108 art files are measured but not certified. | observed + UNVERIFIED | Require `BUILD_ART_BATCH_01.md` to land and pass before C1–C7; re-run the manifest checks independently (S5/S6 already agree). |
| R2 | Concurrent NATION-MODEL-01 ownership of `world3d_entities.gd`; absolute line numbers in S2/S3 are stale. | observed | Patch by symbol; re-read before edit; block until owner releases or approves. |
| R3 | 8-vert minimal meshes (`cena`, `tow1a`, `mara`, 8 Ukrainian base scaffolds) produce degenerate silhouettes; visible scaffold may look wrong. | observed + UNVERIFIED visual | Assert structure only; flag in atom detail; visual A/B required before changing policy. |
| R4 | `_apply_tint()` surface overrides are indexed to the **old** mesh; stage mesh with different surface count loses player tint. | derived from `:960-964` | C5 re-apply or assert equal surface counts; label visual UNVERIFIED. |
| R5 | Per-stage bbox changes centring/height policy vs base bbox; geometry may shift relative to sim footprint. | derived from `:1766-1772,1005-1020` | Keep `scale=1.0`; assert finite AABB; visual A/B required. |
| R6 | Completion scaffold visibility (C4) is an owner decision; keeping the child changes on-screen output vs today. | derived + UNVERIFIED | Do not flip without explicit owner confirmation; atom covers both accepted/rejected branches. |
| R7 | Stage lookup uses raw entity sid `e.get("sid")` at `:1799`, not `_entity_mesh_sid()` result `:1596-1597`; if nation-prefixed 3D art ever lands, stage names diverge. | inferred (latent) | Keep stage art keyed to base sids; document as open question; no change now. |
| R8 | `gat` remains 4-stage selector while `wal` folds to 1..2; both have no art, so currently invisible in output. | observed | Leave unchanged (C8); document Q4. |
| R9 | Port `progress/build_time` ≠ donor `hp/maxhp`; boundaries may occur at different sim moments. | UNVERIFIED (carried from S1 §7) | Keep label; no telemetry claims sim equivalence. |
| R10 | No donor GPU capture possible; stage geometry was never rendered. | observed + NO_VISUAL_PARITY | **No parity claim until visual A/B** per `WAVE7_3D_VARIANT_CHARTER.md:29-38`. |
| R11 | Integrated `variant3d/selftest.json` is currently red (`passed:false`). | observed | Atom-only; never claim the integrated gate is green. |
| R12 | Death stages (`_death1/_death2`, `debris`) remain absent; 30+30-frame port event does not exist. | observed | Explicitly out of scope in all four tickets. |

## 6. Open questions

1. **Q1 — Completion scaffold.** Accept C4 (visible `<sid>a`, donor
   `ontagstates.inc:112-127`) or keep the hidden/freed path with PORT
   APPROXIMATION? Owner decision.
2. **Q2 — Batch certification.** Who lands `BUILD_ART_BATCH_01.md` and re-runs
   the 172-asset hash gate + 108-mesh `load()` gate?
3. **Q3 — Tint policy.** Re-apply `_apply_tint()` on swap, or assert surface
   parity and leave as-is; if re-applying, use base sid or stage art sid for
   `_measure_band()`?
4. **Q4 — `gat` wall rule.** Fold `gat` into 1..2 like `wal`, or keep the
   current `wal`-only check?
5. **Q5 — Per-stage bbox authority.** Use the manifest bbox verbatim, as
   specified in C1, or retain the base bbox for footprint stability?
6. **Q6 — Scaffold material.** Use the imported `scaffold.png` MTL from the
   converted OBJs, or an explicit port material? Donor engine-side shader/blend
   is UNVERIFIED.
7. **Q7 — 8-vert meshes.** Intentional minimal LOD or empty placeholders?
   Header/vertex count cannot answer; render test needed.
8. **Q8 — Owner sequencing.** Will NATION-MODEL-01 finish before C1–C7 are
   applied, and who owns the resulting `world3d_entities.gd` diff?

## 7. Summary

- **Observed:** the 108 stage/scaffold OBJs and the 280-entry manifest are on
  disk (12 art-bearing non-wall sids), but `BUILD_ART_BATCH_01.md` has not
  landed; the pre-batch manifest backup shows 172 → 280 with **0** base bbox
  changes. The runtime selector already probes exactly the generated names.
- **Integration plan:** six minimal edits confined to the BUILD-STAGES-01
  seams — per-stage bbox lookup (C1), no selector change (C2), automatic
  visible stage scaffold (C3), opt-in visible completion scaffold (C4),
  tint re-application (C5), telemetry/probe/label honesty (C6–C7) — while
  leaving rotor, nation fix, build-order action, tree pool, motion blocks and
  every public API byte-identical (§3).
- **Assertion:** an atom-only 64² runtime test asserting `cen1/cen2/cen3/cen4`
  parent meshes and `cen1a..cen4a` visible scaffolds at p=0/.25/.5/.75, the
  derived stage-4 clamp at p=1 unfinished, the base mesh + `cena` completion
  path, wall fold `1/2`, positive telemetry, and exit 0 / stderr 0 /
  `SCRIPT ERROR == 0` — with no test weakening.
- **Honesty:** plan only; no file other than this report was written; all
  load-bearing claims are labelled observed/derived/inferred/UNVERIFIED and
  **no visual parity is claimed until a donor-vs-port A/B capture exists**.

*End of BUILD-STAGE-INTEGRATION-01 report. Read-only planning; owner file not edited.*
