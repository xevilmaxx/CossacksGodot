---
id: QA-STAGE-IMPORT-01
owner: QA-STAGE-IMPORT-01 (read-only QA subagent)
role: "Verify the Godot import sidecars for the 108 new stage assets after STAGE-IMPORT-01 lands"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: IMPORT_JOB_PENDING__ZERO_STAGE_SIDECARS__RUNTIME_LOAD_UNVERIFIED__DO_NOT_PROMOTE__NO_PARITY_CLAIM
scope: "Read-only. No code edit, no asset/sidecar write, no runner job submitted, no git operation. Only this report was written."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owns:
  - docs/coord_swarm_2026-11-25/reports/QA_STAGE_IMPORT_01.md
sources_read:
  - docs/coord_swarm_2026-11-25/reports/BUILD_ART_BATCH_01.md
  - docs/coord_swarm_2026-11-25/reports/QA_BUILD_ART_01.md
  - docs/coord_swarm_2026-11-25/reports/BUILD_STAGE_INTEGRATION_01.md
  - docs/coord_swarm_2026-11-25/SWARM_BOARD.md
  - docs/coord_swarm_2026-11-25/reports/ASSET_IMPORT_01.md
  - docs/coord_swarm_2026-11-25/reports/GDIGNORE_01.md
  - variant3d/assets/models/obj/**
  - variant3d/assets/models/tex/scaffold.png
  - variant3d/.godot/imported/**
  - variant3d/.godot_queue/{jobs,results,status.json,now_serving}
batch_report_status: "STAGE_IMPORT_01.md ABSENT — recursive glob under swarm reports found no such file at QA time"
labels: [observed, derived, inferred, UNVERIFIED, NO_VISUAL_PARITY]
parity: "NO PARITY CLAIM — no donor render, no port load, no visual A/B capture"
snapshot: "2026-11-25 ~12:18 local; queue now_serving=530; status.json history ends at ticket 529"
---

# QA-STAGE-IMPORT-01 — read-only verification of the stage-asset Godot import sidecars

> [!IMPORTANT]
> **STAGE-IMPORT-01 has NOT landed/succeeded.** Its own report
> (`reports/STAGE_IMPORT_01.md`) is absent, its `--import` runner job is still
> **queued** (ticket 534), and **zero** of the 108 new stage OBJs and
> `scaffold.png` have an on-disk Godot sidecar. **Runtime load is UNVERIFIED and
> this pass must not be promoted** to an "import verified" status. No parity
> claim is made.
>
> Labels: **observed** = literal bytes/files read this pass; **derived** =
> arithmetic/convention consequence of observations; **inferred** = strong but
> indirect synthesis; **UNVERIFIED** = no readable evidence or no runtime/visual
> capture.

## 1. Sources, scope and method

| # | Source | Use | Label |
|---|---|---|---|
| S1 | `reports/STAGE_IMPORT_01.md` | **ABSENT** — recursive glob found no file anywhere under `docs/coord_swarm_2026-11-25/reports/` at QA time. Import self-report cannot be cross-checked. | UNVERIFIED |
| S2 | `reports/BUILD_ART_BATCH_01.md` (206 lines, read in full) | Authoritative batch result: 108 new stage OBJ+MTL, `scaffold.png`, manifest 172→280; explicitly states the 108 new OBJs had **no `.obj.import` sidecars** because no Godot import was performed (`:161`). | observed |
| S3 | `reports/QA_BUILD_ART_01.md` (248 lines, read in full) | Independent prior QA: counts/resolution PASS, runtime `load()`-as-Mesh UNVERIFIED, no promotion; batch report was absent at *its* time (now landed). | observed |
| S4 | `reports/BUILD_STAGE_INTEGRATION_01.md` (284 lines) | Integration plan C1–C7 and 64² atom spec; states "do not integrate before the asset batch report lands and its gates pass" (`:142-147`). | observed |
| S5 | `SWARM_BOARD.md` | `STAGE-IMPORT-01` (`:330`, session `ses_ded965563ffeTd4GzdVLeZkySd`) = **RUNNING**; `QA-STAGE-IMPORT-01` (`:332`) = RUNNING. `ASSET-IMPORT-01` (`:213`) is the analogous rotor import precedent. | observed |
| S6 | `variant3d/assets/models/obj/**`, `variant3d/assets/models/tex/scaffold.png` | Read-only recursive `glob` + `os.path` + per-file `.import` text parse. | observed |
| S7 | `variant3d/.godot/imported/**` | Read-only `os.listdir` of generated resources (`.mesh`, `.ctex`). | observed |
| S8 | `variant3d/.godot_queue/{jobs,results,status.json,now_serving}` | Read-only queue state for the import job. | observed |
| S9 | `reports/ASSET_IMPORT_01.md`, `reports/GDIGNORE_01.md` | Precedent: a successful `--import` produces sidecars/ctex; stale `.import` under `.gdignore` can advertise a ctex Godot never makes (the rotor defect). | observed |

The stage OBJ set is **12 non-wall sids × 9 suffixes** = `cen, hou, bar, sta,
bla, aca, art, dip, sto, mil, mar, tow` × `1,2,3,4,1a,2a,3a,4a,a` (derived
from S2 §4/§7 and S3 §2.1; confirmed present on disk this pass).

## 2. Counts table

All values observed at the §snapshot unless marked otherwise. "Expected" is the
convention measured from the 172 pre-existing base OBJs in the same directory
(derived): each base OBJ has exactly one `<name>.obj.import` with an **inline**
`uid=` field; there are **no standalone `.uid` files** in `obj/`.

| # | Check | Expected / convention | Observed | Label |
|---|---|---|---|---|
| 1 | Stage OBJ files on disk | 108 | **108** (0 missing) | observed |
| 2 | `.obj` files in `obj/` total | 280 (172 base + 108 stage) | **280** | observed |
| 3 | `.import` files in `obj/` total | 172 (base only, until import runs) | **172** | observed |
| 4 | `.uid` files in `obj/` total (standalone) | 0 (uid is inline in `.import`) | **0** | observed |
| 5 | **Stage `.obj.import` sidecars** | **108** (one per new OBJ) | **0 / 108** — none for any `<sid><suffix>.obj` | observed |
| 6 | **Stage standalone `.obj.uid` sidecars** | 0 by base convention (uid inline) | **0** | observed |
| 7 | `tex/scaffold.png` present | 1 | **1**, 3,700,187 B | observed |
| 8 | **`scaffold.png.import` / `.png.uid`** | 1 `.import` (texture importer), uid inline | **0 / 0** — absent | observed |
| 9 | OBJs lacking a `.import` sidecar | 108 (the new stage set) | **108** — exactly the stage set | observed / derived |
| 10 | Orphan `.import` (no backing OBJ) | 0 | **0** — all 172 sidecars map to a base OBJ | observed |
| 11 | Base `.import` with empty `uid` | 0 | **0** | observed |
| 12 | Base `.import` with empty `path` | 0 | **0** | observed |
| 13 | Base `.import` whose `path` target is missing | 0 | **0** | observed |
| 14 | Generated `.mesh` in `.godot/imported/` | 172 (base), +108 after stage import | **172**; **0** stage-named `.mesh` | observed |
| 15 | Generated `.ctex` in `.godot/imported/` | — | **910**; **0** `scaffold.png-*.ctex` | observed |
| 16 | `.godot/imported/` total entries | — | **2,820** | observed |
| 17 | Stage-import runner job (`stageimport01-import`, ticket 534) | completed, status `ok` | **QUEUED / NO RESULT** — result dir empty, job absent from `status.json` history (`now_serving=530`) | observed |
| 18 | New stage OBJ/MTL/scaffold tracked by git | no sidecars tracked | **untracked**; no `.import`/`.uid` stage sidecar appears in `git status` | observed |

### 2.1 Sidecar content verification

Because there are **no stage sidecars**, `uid` / `path` non-emptiness and target
existence **cannot be verified for the 108 stage assets** — that gate is
**UNVERIFIED (no sidecar exists)**. The 172 base `.import` files were parsed as
a convention/control sample:

| Sample sidecar | `uid` | `path` | Generated target exists |
|---|---|---|---|
| `mil.obj.import` | `uid://bj6xeaa4jyovk` (non-empty) | `res://.godot/imported/mil.obj-ad35d5a1ff6c7c0764e5ecebdaa22f8f.mesh` | **yes** |
| `cen.obj.import` | `uid://co63oed5hu1qa` (non-empty) | `res://.godot/imported/cen.obj-6c589f710c19aa386741d5790112d035.mesh` | **yes** |
| `mine_iron.obj.import` | `uid://bbyo4n0cjbe0i` (non-empty) | `res://.godot/imported/mine_iron.obj-1d37e9428728d634fe33cd30a749b1ba.mesh` | **yes** |

All 172 base sidecars: 0 empty `uid`, 0 empty `path`, 0 missing `path` targets
(observed). This is a reference sample only; it does **not** certify any stage
asset.

### 2.2 Runner / import-job state

- `variant3d/.godot_queue/jobs/00000534.json` = `{"id":"stageimport01-import",
  "ticket":534, "argv":["--headless","--path","variant3d","--import"],
  "timeout":900.0, "created":1795605376.59, "pid":14428}` (observed).
- `variant3d/.godot_queue/results/00000534_stageimport01-import/` exists but is
  **empty** — no `stdout.txt`, `stderr.txt` or result JSON (observed).
- `status.json` history terminates at ticket **529**; ticket 534 is **not**
  present, so no exit code / status is recorded (observed). `now_serving` = **530**.
- Therefore the import job was **still queued, not completed** at this snapshot
  (derived). The board's `RUNNING` state (S5) is consistent with this.

This mirrors S9: a `--import` run is the mechanism that would create the
sidecars; it has not completed, so the absence of sidecars is expected and is
**not** evidence of a failed import — but it is also **not** evidence of a
successful one.

## 3. Verdict

| Gate | Result | Basis | Label |
|---|---|---|---|
| 108 new stage OBJs present on disk | **PASS** | row 1 | observed |
| Stage `.obj.import` sidecars present (108) | **FAIL — 0 present** | rows 3,5,9 | observed |
| Stage `.uid` sidecars present / accounted for | **N/A** — 0 standalone `.uid` by base convention; none for stage files | rows 4,6 | observed / derived |
| `scaffold.png` sidecar present | **FAIL — absent** | row 8 | observed |
| Stage sidecar `uid` / `path` non-empty and target exists | **UNVERIFIED — no sidecar to parse** | §2.1 | UNVERIFIED |
| Sample generated stage resources in `.godot/imported/` | **ABSENT** — 0 stage `.mesh`, 0 scaffold `.ctex` | rows 14–16 | observed |
| Import job `stageimport01-import` completed ok | **UNVERIFIED — queued, no result** | §2.2, row 17 | observed / derived |
| `STAGE_IMPORT_01.md` self-report landed | **ABSENT** | S1 | UNVERIFIED |
| Godot `ResourceLoader.exists()` / `load()`-as-`Mesh` for 108 stage assets | **UNVERIFIED** — no sidecars, no runner, no load probe | §2–§2.2 | UNVERIFIED |
| Visual / donor parity | **NO CLAIM** | no render, no A/B capture | UNVERIFIED |

**Overall verdict: DO NOT PROMOTE.** The exact on-disk state is that the stage
art exists (108 OBJs + `scaffold.png`) but **no Godot import has completed** for
it: 108 stage `.obj.import` sidecars = 0, `scaffold.png.import` = 0, stage
generated `.mesh`/`.ctex` = 0, and the import job is still queued. The runtime
load gate is **UNVERIFIED** and must remain so until STAGE-IMPORT-01 lands, its
job reports `ok`/exit 0, and the sidecars/generated resources are re-checked.

## 4. Remaining integration / atom tickets

None of these were executed or verified by this read-only pass.

1. **STAGE-IMPORT-01** (owner, board `:330`, RUNNING) — finish the queued
   `stageimport01-import` job (ticket 534), land `reports/STAGE_IMPORT_01.md`,
   and produce the 108 stage `.obj.import` + `scaffold.png.import` sidecars and
   their `.godot/imported/` resources. Status: **NOT LANDED / NO SIDECARS**.
2. **BUILD-ART-B / report certification** — `reports/BUILD_ART_BATCH_01.md` has
   now landed (S2) with self-gates; re-verification of the 172-asset SHA-256
   gate and the 108-mesh `load()` gate remains **UNVERIFIED** here. Status:
   **report present / runtime gates unverified**.
3. **BUILD-ART-C / BUILD-STAGE-INTEGRATION-01 — runtime integration**
   (`variant3d/scripts/world3d_entities.gd`, BUILD-STAGES-01 seams only): C1
   per-stage bbox, C2 selector unchanged, C3 visible stage scaffold, C4 owner
   decision on `<sid>a` completion scaffold, C5 tint re-apply/assert, C6–C7
   probe/telemetry/label honesty. S4 explicitly requires the import gates to
   pass before merging. Status: **plan only / UNVERIFIED**.
4. **BUILD-ART-D — 64² atom** (new `variant3d/tests/t_build_stages.gd` + result
   JSON): suffixes 1/2/3/4, stage source string, visible scaffold, per-stage
   bbox, hit counters, runner status ok / exit 0 / stderr 0 bytes /
   `SCRIPT ERROR == 0`; atom-only, never merged with the red integrated
   `selftest.json`. Status: **UNVERIFIED / not started**.
5. **Visual A/B capture** — required before any donor-parity statement.
   Status: **UNVERIFIED / NO_VISUAL_PARITY**.

## 5. Open questions

1. **Q1** — Will ticket 534 complete with status `ok`, and will Godot actually
   generate sidecars for `variant3d/assets/models/obj/` (no `.gdignore` marker
   was found in that tree during this pass)? **UNVERIFIED**.
2. **Q2** — What exact sidecar set does STAGE-IMPORT-01 intend: 108
   `.obj.import` only, or also standalone `.obj.uid`? Base convention is
   inline `uid` and 0 standalone `.uid`; **UNVERIFIED** (no report).
3. **Q3** — `scaffold.png` has no `.import`; will the texture importer create
   one, and which `.ctex` will it advertise? Contrast the S9 rotor defect
   where a stale `.import` advertised a ctex Godot never generated.
   **UNVERIFIED**.
4. **Q4** — Since the 60 scaffold-linked stage MTLs reference
   `..\tex\scaffold.png`, does runtime need the imported texture resource or
   does it decode raw bytes (as the rotor path does)? Ticket C / Q6;
   **UNVERIFIED**.
5. **Q5** — The 10 known minimal 8-vert meshes (`cena`, `mara`, `tow1a`, …)
   convert to near-degenerate geometry; if sidecars land, do they import as
   non-null `Mesh` with surfaces? **UNVERIFIED** (render test needed).
6. **Q6** — Should integration wait for the import job *and* the batch hash/load
   gates, or proceed on the manifest/backup checks already measured? S4 says
   wait; owner decision. **UNVERIFIED**.
7. **Q7** — Snapshot perishability: the queue is live (`now_serving=530`,
   tickets 531–536 queued). Could ticket 534 complete after this pass and
   change every "0" above? Yes — re-run this check before acting on the
   verdict. **UNVERIFIED**.

## 6. Summary

- **What landed:** the **art** — 108 new stage/scaffold `.obj` (12 sids × 9
  suffixes), 108 matching `.mtl`, and `tex/scaffold.png` (3,700,187 B); the
  manifest is 280 entries. No Godot sidecar for any of them.
- **What did NOT land:** STAGE-IMPORT-01's report (`STAGE_IMPORT_01.md`) and its
  import result. Job 534 `stageimport01-import` (`--headless --path variant3d
  --import`) is **queued** with an empty result directory and no `status.json`
  entry.
- **Sidecar counts:** `obj/` holds 280 `.obj`, **172 `.import` (all base)**,
  **0 standalone `.uid`**. Stage `.obj.import` = **0/108**; stage `.uid` = 0
  (base convention has no standalone `.uid`); `scaffold.png.import` = **0**;
  `scaffold.png.uid` = **0**. All 108 OBJs lacking a sidecar are exactly the
  new stage set.
- **Generated resources:** `.godot/imported/` has 2,820 entries, 172 `.mesh`
  (all base), **0 stage-named `.mesh`**, 910 `.ctex` and **0 scaffold `.ctex`**.
- **Reference control:** all 172 base `.import` sidecars have non-empty `uid`
  and `path`, and every advertised target exists (3 samples shown verbatim).
  This does not certify any stage asset.
- **Do not promote:** runtime `load()`-as-`Mesh` is **UNVERIFIED**; the batch's
  runtime gates, BUILD-ART-C, atom D and visual A/B remain outstanding.
  **No visual parity is claimed** — donor geometry was never rendered and no
  A/B capture exists.

*End of QA-STAGE-IMPORT-01 report. Read-only QA; only this file was written; all counts from a snapshot at ~12:18 local with the stage-import job still queued; uncertainties labelled.*
