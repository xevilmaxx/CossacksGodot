---
id: QA-BUILD-ART-01
owner: QA-BUILD-ART-01 (read-only QA subagent)
role: "Verify the generated 108 stage/scaffold assets after BUILD-ART-BATCH-01 lands"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: COUNTS_VERIFIED_ON_DISK__BATCH_REPORT_ABSENT__BATCH_SELF_GATES_UNVERIFIED__NO_PARITY_CLAIM
scope: "Read-only. No code edit, no runner job, no donor access, no asset write. Only this report was written."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owns:
  - docs/coord_swarm_2026-11-25/reports/QA_BUILD_ART_01.md
sources_read:
  - docs/coord_swarm_2026-11-25/reports/BUILD_ART_01.md
  - docs/coord_swarm_2026-11-25/reports/BUILD_ART_CONV_01.md
  - variant3d/assets/models/manifest.json
  - variant3d/assets/models/obj/**
  - variant3d/assets/models/tex/**
batch_report_status: "ABSENT at QA time — docs/.../reports/BUILD_ART_BATCH_01.md does not exist"
labels: [observed, derived, inferred, UNVERIFIED, NO_VISUAL_PARITY]
parity: "NO PARITY CLAIM — donor geometry was not rendered; no A/B capture exists"
---

# QA-BUILD-ART-01 — read-only verification of the generated 108 stage/scaffold assets

> [!IMPORTANT]
> This is a **read-only QA pass**. No source, asset, manifest, config, test or
> report other than this file was written. No donor file was read or copied and
> no Godot runner/visual capture was run. **No visual parity is claimed.**
> Labels: **observed** = literal filesystem / manifest bytes read this pass;
> **derived** = arithmetic or control-flow consequence of observations;
> **inferred** = strong but indirect synthesis; **UNVERIFIED** = no readable
> evidence or no runtime/visual capture.

## 1. Sources and method

| # | Source | Use | Label |
|---|---|---|---|
| S1 | `docs/.../reports/BUILD_ART_01.md` (297 lines, read in full) | Authoritative plan: §3.1 donor sid table, §5 ticket (b) gate criteria, §6 double counts, §7 risks. | observed |
| S2 | `docs/.../reports/BUILD_ART_CONV_01.md` (195 lines, read in full) | Converter-config ticket (a) result: 108 table entries, unique sids, 0 collisions, 0 missing donor files, contributor of the `--include-stages` flag. | observed |
| S3 | `BUILD_ART_BATCH_01.md` | **ABSENT** — recursive search found no file at QA time. Batch self-report cannot be checked. | UNVERIFIED |
| S4 | `variant3d/assets/models/manifest.json` | Parsed with Python `json`; entry count, sid uniqueness, kinds, bbox, `obj_name`/`tex_name`. | observed |
| S5 | `variant3d/assets/models/obj/**`, `tex/**` | Recursive `glob`, per-file `open(..., latin-1)` structure parse, `os.path.getsize`, `os.path.exists`. | observed |
| S6 | Repo-wide `*.osm`, `*.oss`, `*.dds` glob; `git status --short`, `git diff --name-only`, `git ls-files --others` | Donor-copy guard and base-asset identity check. | observed |

Snap timing (observed): the asset tree was **in flight** during the first QA reads —
counts moved `230 → 248 → 279 → 280` across successive samples. A stable snapshot
was taken afterwards: `280` `.obj` files unchanged across two reads 4 s apart,
`280` `.mtl` files, `scaffold.png` present at 3,700,187 B. All numbers below come
from that stable snapshot.

## 2. Inventory table

Expected values are from BUILD-ART-01 §5 ticket (b) gate criteria (S1). All
"Observed" values are from S4/S5/S6 at the stable snapshot.

| # | Check | Expected | Observed | Method / evidence | Label |
|---|---|---|---|---|---|
| 1 | `.obj` files total | 280 (172 base + 108 new) | **280** | recursive `glob(**/*.obj)` | observed |
| 2 | `.mtl` files total | 280 | **280** | recursive `glob(**/*.mtl)` | observed |
| 3 | OBJ/MTL stem set equality | equal | **equal** (280 = 280) | set of `name[:-4]` | derived |
| 4 | New `.obj` (beyond 172) | 108 | **108** | `git ls-files --others` → 108 untracked `.obj` | observed |
| 5 | New `.mtl` (beyond 172) | 108 | **108** | `git ls-files --others` → 108 untracked `.mtl` | observed |
| 6 | `tex/scaffold.png` | 1 new | **1 new**, untracked, 3,700,187 B | `stat` + `git status` | observed |
| 7 | Manifest entries | 280 | **280** | `len(manifest["models"])` | observed |
| 8 | Manifest unique sids | 280 | **280** | `len(set(sids))` | observed |
| 9 | Manifest sid collisions | 0 | **0** | `Counter` duplicates | observed |
| 10 | Manifest kinds | 62 unit / 125 building / 93 env | **62 / 125 / 93** (building 17 base + 108 stage) | `Counter(kind)` | observed / derived |
| 11 | Base 17 building sids intact | 17 | **17** | membership check (`cen..dip`, `wal`, `gat`, 3 mines) | observed |
| 12 | Stage sids in manifest | 108 | **108 / 108**, 0 missing | 12 sids × 9 suffixes | observed |
| 13 | Stage sid → file resolution | 108 / 108 | **108 / 108** | `obj_name == sid` for all 108; `<sid>.obj` exists for all 108 | observed / derived |
| 14 | Stage OBJ structural sanity | all pass | **108 / 108 pass** (`mtllib`, `o `, ≥1 `v`, ≥1 `vt`, ≥1 `f`) | line parse | observed |
| 15 | Stage OBJ converter header | all pass | **108 / 108** identical first line: `# Cossacks 3 original mesh, converted by tools/convert_models.py` | line parse | observed |
| 16 | Stage MTL texture links resolve | 108 / 108 | **108 / 108**, 0 missing | `map_Kd` + `os.path.exists` | observed |
| 17 | Stage MTL `map_Kd` split | 60 scaffold + 48 base PNG | **60 `..\tex\scaffold.png` + 48 base PNGs (4 per sid × 12)** | `Counter` | observed |
| 18 | Stage bbox = 6 numbers | 108 / 108 | **108 / 108** | `len(bbox)==6` numeric | observed |
| 19 | Pre-existing tracked `.obj`/`.mtl`/`.png` modified | 0 | **0** | `git diff --name-only -- obj tex` → empty | observed |
| 20 | Donor `.osm` copied into repo | 0 | **0** | repo-wide glob | observed |
| 21 | Donor `.oss` copied into repo | 0 | **0** | repo-wide glob | observed |
| 22 | `.dds` in repo | pre-existing only | **936**, newest mtime **2026-11-20** (before all tickets) | repo-wide glob + mtime | observed |
| 23 | `debris.png` | absent (death stages out of scope) | **absent** | `os.path.exists` | observed |
| 24 | Known 660-byte donor cases | 10 flagged as data | **10 tiny OBJ outputs** (9 at 801 B, 1 at 802 B) with near-zero bbox extents | filesize + bbox | observed / derived |

### 2.1 Stage sid resolution detail

12 non-wall sids × 9 suffixes = 108; every cell below is present both in the
manifest and as `<sid><suffix>.obj` + `.mtl` on disk. (Label: observed.)

| sid | 1 | 2 | 3 | 4 | 1a | 2a | 3a | 4a | a | count |
|---|---|---|---|---|---|---|---|---|---|---|
| cen | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| hou | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| bar | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| sta | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| bla | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| aca | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| art | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| dip | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| sto | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| mil | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| mar | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |
| tow | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 9/9 |

Parent entries (48) use `tex_name` = the building's base sid; all 60 attach/base
entries use `tex_name = scaffold`. This matches the converter-config ticket's
documented `tex_name` tally (S2 §4) and avoids duplicate PNG emission.
(Label: observed for the on-disk manifest; agreement with the plan is derived.)

### 2.2 The 10 known 660-byte cases — recorded as data, not errors

BUILD-ART-01 §3.1/R1 and BUILD-ART-CONV-01 §2 flagged 10 donor `.osm` files that
are valid but minimal 660-byte IDP2 meshes (8 verts / 12 UVs / 12 tris). Their
converted port outputs are present and measurably degenerate (Label: observed;
visual role **UNVERIFIED**):

| Port output | Donor source | `.obj` size | bbox extent (derived) |
|---|---|---:|---|
| `cena.obj` | `ukrcena.osm` (660 B) | 801 B | ~0.044 × 0.044 XY, Z −0.0508..−0.0064 |
| `houa.obj` | `ukrhoua.osm` (660 B) | 801 B | near-zero |
| `bara.obj` | `ukrbara.osm` (660 B) | 801 B | near-zero |
| `staa.obj` | `ukrstaa.osm` (660 B) | 801 B | near-zero |
| `blaa.obj` | `ukrblaa.osm` (660 B) | 801 B | near-zero |
| `acaa.obj` | `ukracaa.osm` (660 B) | 801 B | near-zero |
| `arta.obj` | `ukrarta.osm` (660 B) | 801 B | near-zero |
| `dipa.obj` | `ukrdipa.osm` (660 B) | 801 B | near-zero |
| `mara.obj` | `eurmara.osm` (660 B) | 801 B | near-zero |
| `tow1a.obj` | `eurtow1a.osm` (660 B) | 802 B | near-zero |

These are **not parse failures** — all 10 passed the structural-sanity check
(row 14). They are recorded as data only; whether they represent intentional
minimal LOD geometry or empty placeholders is **UNVERIFIED** (requires a render
test). No parity or visual-correctness claim is made about them.

## 3. Verdict

| Gate (from BUILD-ART-01 §5 ticket b) | Result | Basis | Label |
|---|---|---|---|
| (1) File counts exact: +108 `.obj`, +108 `.mtl`, +1 `.png`, manifest 280 | **PASS on disk** | rows 1–8 | observed |
| (1b) Manifest 280 unique sids, 0 collisions | **PASS on disk** | rows 8–9 | observed |
| (1c) Each stage sid resolves to a file | **PASS on disk** | rows 12–15, §2.1 | observed / derived |
| (2) Every new OBJ has converter header, `mtllib`, `o model`, `v`, `vt`, `f` | **PASS on disk** | rows 14–15 | observed |
| (2b) Godot `ResourceLoader.exists()` **and** `load()` non-null as `Mesh` for all 108 | **UNVERIFIED** | no runner job was run in this QA; batch report absent | UNVERIFIED |
| (3) SHA-256 of all 172 pre-existing assets unchanged | **PARTIAL / observed proxy** | `git diff --name-only` reports **0** modified tracked `.obj`/`.mtl`/`.png`; a direct SHA-256-to-baseline comparison was not available in this QA | observed (git), full hash gate UNVERIFIED |
| (3b) Base sid bboxes unchanged | **UNVERIFIED** | no pre-batch JSON baseline was available in this QA | UNVERIFIED |
| (4) No donor-extension file anywhere in repo | **PASS on disk** | rows 20–22 | observed |
| (5) 10 known 660-byte cases flagged | **PASS as data** | §2.2 | observed / derived |
| Batch's own written report (`BUILD_ART_BATCH_01.md`) | **ABSENT** | S3 | UNVERIFIED |
| Visual / donor parity | **NO CLAIM** | no A/B capture | UNVERIFIED |

**Overall verdict:** the **asset-count and asset-resolution checks PASS** against
the stable on-disk snapshot: 280 `.obj` + 280 `.mtl` (172 base + 108 new), 1 new
`scaffold.png`, manifest 280 entries with 280 unique sids and 0 collisions, and
all 108 stage sids resolving to structurally valid files whose MTL texture links
all exist. The donor-copy guard also passes (0 `.osm`, 0 `.oss`; 936 `.dds` all
pre-existing).

**However, do not promote this to a "batch verified" status:** the batch's own
report has **not landed**, and the runtime-load gate (`load()` as `Mesh`),
byte-for-byte hash equality and base-bbox equality remain **UNVERIFIED** in this
QA. The batch generation was still in flight when QA began and only became
stable during the pass; the on-disk state is now stable but no batch-authored
gate evidence exists to cross-check against. **No parity claim is made.**

## 4. Remaining integration tickets

Carried forward from S1 §5 / S2 §5, with QA status annotations. None of these
were executed or verified by this read-only pass.

1. **BUILD-ART-B (asset batch) — report landing.** Artifacts are on disk (this
   report verifies counts), but `docs/.../reports/BUILD_ART_BATCH_01.md` is
   **absent**. Still required: author lands the report with its own gate
   evidence (SHA-256 of 172 base assets, base-bbox equality, Godot load-as-Mesh
   result, exit/stderr). Status: **artifacts present / report UNVERIFIED**.
2. **BUILD-ART-C — runtime integration** (`variant3d/scripts/world3d_entities.gd`,
   BUILD-STAGES-01 block only): read per-stage bbox from `_bbox[sid+suffix]`,
   resolve the 108 OBJ names, make the scaffold child visible, use `<sid>a` at
   completion, stop unconditional "no stage OBJ" telemetry, decide `gat`
   wall-rule handling, re-apply player tint after a mesh swap. QA observation:
   `world3d_entities.gd` is modified in `git status`, but whether BUILD-ART-C has
   landed is **UNVERIFIED** and out of scope here. Status: **UNVERIFIED**.
3. **BUILD-ART-D — 64² runtime assertion** (new atom `t_build_stages.gd` + result
   JSON): runner status ok, exit 0, stderr 0 bytes, `SCRIPT ERROR == 0`;
   atom-only, never merged with the integrated `selftest.json`. Status:
   **UNVERIFIED**.
4. **Visual A/B capture** — required before any donor-parity statement. Status:
   **UNVERIFIED / NO_VISUAL_PARITY**.
5. **Owner decision on the 10 minimal meshes** (§2.2) — accept as minimal LOD or
   treat as placeholders needing replacement, and whether `wal`/`gat` art should
   ever be added. Status: **open**.

## 5. Open questions

Carried from S1 §8 / S2 §7; QA adds Q9–Q11.

1. **Q1** — Should the completion scaffold `<sid>a` be visible, matching
   `ontagstates.inc:112-127`, or stay hidden/freed with a PORT APPROXIMATION
   label? Owner decision, ticket c.
2. **Q2** — Authoritative `wal` / `gat` stage actor remains UNVERIFIED; no wall
   or gate entries were added.
3. **Q3** — Are the 660-byte IDP2 meshes intentional minimal LOD or empty
   placeholders? Now confirmed to produce 10 tiny port OBJs (§2.2); render test
   still needed.
4. **Q4** — Should `gat` be folded to stages 1..2 like `wal` in
   `_build_stage_suffix()`?
5. **Q5** — Re-apply tint after a stage mesh swap, or assert identical surface
   counts? Ticket c.
6. **Q6** — Use the imported MTL from `scaffold.png` or an explicit port
   material? Donor engine-side shader/blend is UNVERIFIED.
7. **Q7** — Death stages (`_death1` / `_death2`, `debris.dds`) stay deferred; no
   port event supplies 30+30-frame timing. `debris.png` confirmed absent.
8. **Q8** — Per-stage bbox presence is confirmed (108/108, row 18), but whether
   the runtime actually consumes it is ticket c / **UNVERIFIED**.
9. **Q9 (QA)** — Why is `BUILD_ART_BATCH_01.md` absent although its artifacts are
   fully present and stable? Was the report simply not written yet, or was the
   batch run outside the documented ticket flow? **UNVERIFIED**.
10. **Q10 (QA)** — Can a direct SHA-256 baseline for the 172 pre-existing assets
    be produced (e.g. from git HEAD or the pre-batch backup) so gate (3) can be
    upgraded from a git-diff proxy to a byte-for-byte PASS? **UNVERIFIED**.
11. **Q11 (QA)** — The batch was observed mid-generation (`230→248→279→280`).
    Is the final `280` state the intended terminal state, or could another
    writer still append/modify assets? Snapshot was stable over 4 s, but no
    batch-authored completion marker exists. **UNVERIFIED**.

## 6. Summary

- **What landed:** after the converter-config ticket (S2), the asset batch wrote
  **108 new `.obj` + 108 new `.mtl`**, one new `tex/scaffold.png` (3,700,187 B),
  and grew the manifest from **172 → 280** entries. On-disk state is stable at
  **280 `.obj` / 280 `.mtl`** (172 base + 108 new), all 108 new files untracked.
- **Counts / resolution:** manifest has **280 unique sids, 0 collisions**; kinds
  62 unit / 125 building / 93 env; the 17 base building sids are intact; all
  **108** stage sids resolve to a real `.obj`/`.mtl`; all 108 OBJs pass structural
  sanity and carry the converter header; all 108 MTL texture links resolve
  (60 scaffold + 48 base PNGs); all 108 entries carry a 6-number bbox.
- **Guards:** **0** `.osm`, **0** `.oss` in the repo; **936** `.dds` all pre-existing
  (newest 2026-11-20); **0** tracked base obj/mtl/png modifications; `debris.png`
  absent as expected.
- **Known data:** the 10 documented 660-byte donor cases convert to 10 tiny port
  OBJs (801–802 B, near-zero bbox) — flagged as data, not errors; visual role
  **UNVERIFIED**.
- **What is not verified:** the batch's own report is **absent**; Godot
  load-as-Mesh, byte-for-byte SHA-256 of the 172 base assets and base-bbox
  equality remain **UNVERIFIED**; runtime integration (BUILD-ART-C) and the 64²
  atom (BUILD-ART-D) are outstanding.
- **Promotion:** **do not promote** to "batch verified" until the batch report
  lands and its runtime-load/hash gates are evidenced. **No visual parity claim**
  is made — donor geometry was never rendered and no A/B capture exists.

*End of QA-BUILD-ART-01 report. Read-only QA; only this file was written; all counts from a stable on-disk snapshot; uncertainties labelled.*
