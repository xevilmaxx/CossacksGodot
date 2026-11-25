---
id: BUILD-ART-BATCH-01
owner: BUILD-ART-BATCH-01 (asset-batch builder subagent)
role: "Run the opt-in --include-stages conversion, register 108 donor construction-stage / scaffold OBJ assets and update the port model manifest"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: DONE__ASSET_BATCH_ONLY__NO_GODOT__NO_RUNNER__NO_PARITY_CLAIM
scope: "Edited ONLY generated files under variant3d/assets/models/obj/**, variant3d/assets/models/tex/scaffold.png, variant3d/assets/models/manifest.json, the required manifest backup and this report. Donor READ-ONLY. No converter, runtime script, test, config or app/** file touched."
owns:
  - variant3d/assets/models/obj/**
  - variant3d/assets/models/tex/scaffold.png
  - variant3d/assets/models/manifest.json
  - docs/coord_swarm_2026-11-25/reports/BUILD_ART_BATCH_01.md
backup: inbox/backup/manifest.json.bak-BUILDARTBATCH (129,369 B, SHA-256 b485b2912b543dd52407382c4670ecd74dd274b451e423b6f0c13d2aa128450e, taken before first write)
labels: [observed, derived, UNVERIFIED, NO_VISUAL_PARITY]
---

# BUILD-ART-BATCH-01 — asset batch: 108 donor construction-stage / scaffold meshes

> [!IMPORTANT]
> This ticket is the **b** step of the ordered a → b → c → d plan from
> `BUILD_ART_01.md` §5. The converter's opt-in `--include-stages` table from
> `BUILD_ART_CONV_01.md` was executed once into the port model root. **No Godot
> runner, no game launch, no visual A/B and no donor copy was performed.**
> Every parity statement remains **UNVERIFIED**.

## 1. Sources read (read-only)

| Input | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/BUILD_ART_01.md` (297 lines) | Authoritative plan: §3.1 donor sid table, §5 ticket (b) gates, §6 double counts, §7 risks R1–R13. |
| `docs/coord_swarm_2026-11-25/reports/BUILD_ART_CONV_01.md` (195 lines) | Ticket (a) result: 108-entry `stage_models()`, `--include-stages`, 0 missing donor files, 0 collisions. |
| `variant3d/tools/convert_models.py` | CLI read at `:499-509` (`--game`, `--out`, `--include-stages`); write path at `:514-541`; bbox/manifest at `:544-562`; docstring `:1-25` (static bind-pose disclaimer). Not edited. |
| `variant3d/assets/models/manifest.json` | 172-entry baseline; located read-only (no `objects.json` exists). Kinds: env 93 / unit 62 / building 17. |
| `.gitignore` | Generated OBJ/MTL/PNG under `variant3d/assets/models/` are **trackable**: the legacy global `obj/` ignore is explicitly re-included by `!variant3d/assets/models/obj/` and `!variant3d/assets/models/obj/**`; `models/tex` PNGs are not ignored. Donor extensions are never to be committed. |
| `app/tools/convert_models.py`, `app/assets/models/**`, `variant3d/scripts/world3d_entities.gd` | Located/compared read-only only; not edited. |

**Pre-state:** `variant3d/assets/models/obj` = 172 `.obj` + 172 `.mtl`; `variant3d/assets/models/tex` = 173 `.png`; `scaffold.png` absent. Note `app/assets/models/obj` holds only 116 `.obj` — it is *not* the same directory as the variant3d one, despite the `.gitignore` hardlink comment.

## 2. Backup

```
Copy-Item -LiteralPath "variant3d\assets\models\manifest.json" `
          -Destination "inbox\backup\manifest.json.bak-BUILDARTBATCH" -Force
```

Backup size 129,369 B; SHA-256 `b485b2912b543dd52407382c4670ecd74dd274b451e423b6f0c13d2aa128450e`, identical to the live manifest at backup time. Before any write, a read-only SHA-256 snapshot was taken of all 172 `.obj`, 172 `.mtl` and 173 `.png` files (snapshot kept in the OS temp folder, not in the repo).

## 3. Exact converter command and result

Run from the repository root with `python` (Python **3.14.3**, `C:\Python314\python.exe`; Pillow **12.1.1**; `COSSACKS3_DIR` unset):

```
python variant3d/tools/convert_models.py --game "C:\Games\Cossacks 3" --out variant3d/assets/models --include-stages
```

Resolved invocation used by the capturing wrapper:
`C:\Python314\python.exe variant3d/tools/convert_models.py --game "C:\Games\Cossacks 3" --out variant3d/assets/models --include-stages`

| Metric | Value |
|---|---|
| Exit code | **0** |
| Wall runtime | **191.444 s** |
| stdout | 281 lines = **280 `OK …`** + 1 `done:`; **0 `MISSING`** lines |
| stderr | **0 bytes** |
| `done:` line | `done: 280 models, manifest at …\variant3d\assets\models\manifest.json` |

stdout head (verbatim):
```
OK peasant      oss      verts=577   faces=921   bbox z 0.01..2.00
OK pikeman      oss      verts=733   faces=1062  bbox z 0.00..3.52
OK roundshier   oss      verts=710   faces=1048  bbox z 0.00..1.97
```
stdout tail (verbatim):
```
OK tow3         osm      verts=1272  faces=1052  bbox z -0.05..4.78
OK tow4         osm      verts=1711  faces=1360  bbox z -0.05..9.38
OK tow1a        osm      verts=8     faces=12    bbox z -0.05..-0.01
OK tow2a        osm      verts=4170  faces=2669  bbox z -0.08..4.46
OK tow3a        osm      verts=4060  faces=2432  bbox z -0.03..4.46
OK tow4a        osm      verts=4275  faces=2675  bbox z -0.03..4.46
OK towa         osm      verts=878   faces=1264  bbox z -0.09..2.08
done: 280 models, manifest at C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\assets\models\manifest.json
```

Full stdout/stderr were captured to OS temp files for this ticket; nothing was written into the repo for logs.

## 4. Output counts and hashes (**observed**)

| Item | Before | After | Delta |
|---|---:|---:|---:|
| `.obj` in `obj/` | 172 | **280** | +108 |
| `.mtl` in `obj/` | 172 | **280** | +108 |
| `.png` in `tex/` | 173 | **174** | +1 (`scaffold.png`) |
| manifest models | 172 | **280** | +108 |
| unique sids | 172 | **280** | 0 duplicates |
| stage/base sid collisions | — | **0** | — |

New-file breakdown (by set difference against the pre-state snapshot):

- **108** new `.obj`, **108** new `.mtl`, **1** new `.png` (`scaffold.png`); **0** zero-size files.
- Stage sid categories: **48** parent digit-suffixed (`<sid>1..4`), **48** attach stage (`<sid>1a..4a`), **12** base scaffold (`<sid>a`).
- Texture reuse: **60** stage entries resolve to `scaffold.png`; the other **48** resolve to the 12 existing base building PNGs (4 each).
- New OBJ sizes: min **801 B**, median **286,581 B**, max **1,343,666 B**, total **32,205,527 B**. New MTL total **5,376 B**.

Hashes (SHA-256):

| Object | Hash |
|---|---|
| `manifest.json` before (= backup) | `b485b2912b543dd52407382c4670ecd74dd274b451e423b6f0c13d2aa128450e` |
| `manifest.json` after | `d9789ada402f4311f982f405ce71f6ce106d7bc30e0b0932b63c55bc0b192a81` |
| `tex/scaffold.png` (3,700,187 B) | `d7c259ae35f13f6662cec9c70f3ae292e4786a6187926360cdca63524e8b1007` |
| Aggregate of the 108 new `.obj` (sorted name + bytes) | `3a7c2afcb6f031373faa3cd63982daece3b0240d6ec41d57dd1388720dfc2363` |
| Aggregate of the 108 new `.mtl` (sorted name + bytes) | `895eff7e3e05720034532b795fe6507a9a1c1171398fdb816e447add1acc283a` |

**Base-asset hash gate:** all 172 pre-existing `.obj`, all 172 `.mtl` and all 173 `.png` are byte-identical to the pre-run snapshot — **0 / 0 / 0 changed files**. `git status` likewise reports no modification to any pre-existing OBJ/MTL/PNG.

## 5. Manifest before → after (**observed**)

- `models`: **172 → 280**; `game` unchanged (`C:\Games\Cossacks 3`).
- All **172** original sids retained, **0** duplicates, **0** collisions introduced by the **108** new sids.
- Base bboxes: **0 changed** (compared entry-by-entry against the pre-run snapshot).
- All **280** `obj` paths and all **280** `texture_png` paths resolve to existing files (**0 missing**).
- All 108 new entries have `kind="building"`, a **6-number** bbox and donor-side `mesh`/`texture` provenance fields.
- **Path-normalisation observation:** 116 of the 172 pre-existing entries had `obj` paths under `app\assets\models\obj\` (matching the older 116-object app tree); the run rewrote those to `variant3d\assets\models\obj\`. The other 56 already pointed into `variant3d\assets`. This changes only path strings — bboxes, verts, faces and all asset bytes are unchanged — and makes every manifest path self-consistent with the `res://assets/models/manifest.json` that `world3d_entities.gd:87` loads. No base asset was moved or deleted.

## 6. Known exceptions — data, not errors

The 10 known **660-byte donor IDP2** cases from `BUILD_ART_01` risk R1 / `BUILD_ART_CONV_01` §2 converted cleanly as minimal meshes (8 verts / 12 faces), producing 801–802-byte OBJs. They are flagged, not treated as failures:

| Stage sid | Donor mesh | Output OBJ | Texture |
|---|---|---:|---|
| `cena` | `ukrcena.osm` | 801 B | `scaffold.png` |
| `houa` | `ukrhoua.osm` | 801 B | `scaffold.png` |
| `bara` | `ukrbara.osm` | 801 B | `scaffold.png` |
| `staa` | `ukrstaa.osm` | 801 B | `scaffold.png` |
| `blaa` | `ukrblaa.osm` | 801 B | `scaffold.png` |
| `acaa` | `ukracaa.osm` | 801 B | `scaffold.png` |
| `arta` | `ukrarta.osm` | 801 B | `scaffold.png` |
| `dipa` | `ukrdipa.osm` | 801 B | `scaffold.png` |
| `mara` | `eurmara.osm` | 801 B | `scaffold.png` |
| `tow1a` | `eurtow1a.osm` | 802 B | `scaffold.png` |

Their visual role is still **UNVERIFIED** — a header parse cannot say whether they are intentional minimal LOD geometry or empty placeholders.

## 7. Verification (**observed**, read-only Python/PowerShell)

| Gate | Result |
|---|---|
| 108 new `.obj` + 108 new `.mtl`, non-zero size | **PASS** — exact set differences; 0 zero-size |
| New OBJ structure | **PASS** — all 108 start with `# Cossacks 3 original mesh…`, contain `mtllib <sid>.mtl`, `o model`, ≥1 `v`, ≥1 `vt`, ≥1 `f` |
| New MTL structure | **PASS** — all 108 have `newmtl model`, `Kd 1 1 1`, `map_Kd ..\tex\<sid>.png`; every referenced PNG exists |
| `scaffold.png` | **PASS** — created, 3,700,187 B, hash above |
| Manifest 280 unique sids / 0 collisions | **PASS** |
| Stage sids resolve to files | **PASS** — all 280 `obj`/`texture_png` paths exist on disk |
| Base 172 asset hashes unchanged | **PASS** — 0 / 0 / 0 changed |
| Base bboxes unchanged | **PASS** — 0 changed |
| No donor file copied | **PASS** — repo census: **0 `.osm`, 0 `.oss`**, **936 `.dds`** (all pre-existing; **0** with mtime inside the run window) |
| Scope guard | **PASS** — `git status --short -- <owned paths>` shows only the new OBJ/MTL/scaffold, the modified manifest and the backup; no converter/script/test/config/`app/**` change attributable to this ticket |

**Not run (explicitly out of scope, therefore UNVERIFIED):** Godot `ResourceLoader.exists()` / `load()`-as-`Mesh` for the 108 files, and visual A/B capture. Consistent with that, the 108 new OBJs have **no `.obj.import` sidecars** (172 pre-existing sidecars remain, none for stage files) because no Godot import was performed. Ticket (b) plan gate item 2's runtime-load half is therefore **deferred to integration**, not asserted here.

## 8. Remaining tickets (unchanged)

1. **BUILD-ART-C — runtime integration** (`variant3d/scripts/world3d_entities.gd`, restricted to the `BUILD_STAGES_01` block): read per-stage bbox from `_bbox[sid+suffix]` with base fallback, resolve the new 108 OBJ names, make the scaffold child visible with `<sid><suffix>a` art (and `<sid>a` at completion), stop the unconditional "no stage OBJ" telemetry, decide `gat` wall-rule handling in `_build_stage_suffix()`, and re-apply/assert player tint after a mesh swap. Frozen blocks and public signatures must stay unchanged. **Not started here.**
2. **BUILD-ART-D — isolated 64² atom** (new `variant3d/tests/t_build_stages.gd` + result JSON): assert suffixes 1/2/3/4, stage source strings, visible stage scaffold, per-stage bbox, stage/scaffold hit counters; runner status ok, exit 0, stderr 0 bytes, `SCRIPT ERROR == 0`. Atom-only; never merged with the currently red integrated `selftest.json`. **Not started here.**

Ordering remains **a → b → c → d**; (b) is now complete with its measured gates, (c) must not be merged before these counts are acknowledged.

## 9. No-parity claim

**No visual, animation or donor parity is claimed.** The donor was only read as bytes; no donor mesh was rendered and no port mesh was loaded or displayed. Outputs are static bind-pose PORT APPROXIMATIONS per the converter's own docstring (`:21-24`) and the `WAVE7_3D_VARIANT_CHARTER.md:29-38` governing rule. Labels stay `UNVERIFIED` / `NO_VISUAL_PARITY` until an A/B capture exists together with ticket D.

## 10. Open questions (carried forward + one new)

1. **Q1** — Completion scaffold (`<sid>a`) visible per `ontagstates.inc:112-127`, or hidden/freed with a PORT APPROXIMATION label? Owner decision, ticket C.
2. **Q2** — Authoritative `wal` / `gat` stage actor remains UNVERIFIED; no wall/gate entries were added.
3. **Q3** — Are the 10 minimal 8-vert donor meshes intentional LOD or placeholders? Render test needed.
4. **Q4** — Should `gat` fold to stages 1..2 like `wal` in `_build_stage_suffix()`?
5. **Q5** — Re-apply tint after a stage mesh swap, or assert identical surface counts? Ticket C.
6. **Q6** — Use the imported MTL from `scaffold.png` or an explicit port material? Donor shader/blend is engine-side and UNVERIFIED.
7. **Q7** — Death stages (`_death1` / `_death2`, `debris.dds`) remain deferred; no port event supplies 30+30-frame timing.
8. **Q8** — Godot mesh-load / import-sidecar verification was not run here; exact runner flags for atom D remain UNVERIFIED until it executes.
9. **Q9 (new)** — Is the 116-entry `app\assets\models\obj\…` → `variant3d\assets\models\obj\…` manifest path rewrite acceptable to downstream consumers, or should the manifest keep the original app-relative strings? Asset bytes and bboxes are unchanged; ticket C can confirm the runtime only needs basenames/bboxes.

## 11. Files created / modified by this ticket

**Created (218 + 2):**
- `variant3d/assets/models/obj/<sid>1.obj`, `<sid>2.obj`, `<sid>3.obj`, `<sid>4.obj`, `<sid>1a.obj` … `<sid>4a.obj`, `<sid>a.obj` — **108 `.obj`**
- matching **108 `.mtl`** alongside them
- `variant3d/assets/models/tex/scaffold.png`
- `inbox/backup/manifest.json.bak-BUILDARTBATCH`
- this report

**Modified (1):**
- `variant3d/assets/models/manifest.json` (172 → 280 entries; 116 base path strings normalised; bboxes unchanged)

**NOT modified:** `variant3d/tools/convert_models.py`, `variant3d/scripts/world3d_entities.gd`, any test, config, `app/**`, any pre-existing OBJ/MTL/PNG, any donor file.

**Git operations:** none. Only read-only `git status` queries were used; **no `git add`, `git commit`, `git checkout` or staging** was performed. Concurrent foreign changes visible in the repo were left untouched.

## 12. Summary

Executed the opt-in stage conversion once with `python … --include-stages` (exit 0, 0 bytes stderr, 191.4 s, 280 `OK` lines, 0 `MISSING`). The port model root now holds **280 `.obj` / 280 `.mtl`**, a new **`scaffold.png`**, and a **280-entry manifest** with 280 unique sids and 0 stage/base collisions. All 108 new OBJs and MTLs are structurally valid and non-zero; every manifest path resolves; the 172 pre-existing assets are byte-identical and their bboxes unchanged; no donor `.osm`/`.oss`/`.dds` was introduced. The 10 known minimal donor meshes are logged as data. Godot load/import and visual A/B were **not** performed, so **no parity is claimed**. Integration ticket C and atom D remain outstanding; no git operation was performed.

*End of BUILD-ART-BATCH-01 report.*
