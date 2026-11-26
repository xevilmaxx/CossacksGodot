# 12 — QA and integration (from A06; A05 to be appended)

Source: `reports/A06_integration.md` (design only). **No donor parity claim.**
A05's QA harness report has landed and will be merged into this section once its
worker finishes.

## 12.1 Backend seam — AUTHORITATIVE (V05 reconciled P01 + A06) [D]

P01 and A06 are **complementary**: P01 fixes the placement, A06 fixes how the
switch is supplied and proved. A06 is safer on balance; P01 only on file count.

Exactly **two files** are edited, additively:
- **`main.gd`** — 4 inserts: `var` after `:124`; config read after `:185-186`;
  guard call at **both** `:587-588` and `:1104-1105`.
- **`world3d.gd`** — donor const, `backend` var + `_terrain_locked`,
  late-switch-refusing setter, ternary at **`:609`**, stats keys at `:674-692`.

Default `"legacy"`. Byte-identical: the six legacy pipeline files, relief/config/
project/tests/atlas/`app/**`, and `world3d.gd:610-614,631-672,694-769` plus
`main.gd:120-124`. V05's patch sketch is text only, **not applied**.

Multi-pass status note (point-in-time, V26 re-read): V04/V05/V11/V16 audited HEAD `e234ac9b` with `variant3d/`/`app/` clean and the seam unapplied; **A06's E12/E13 and P01/A06-era "three uncommitted Y08b/Y10/Y11 source edits" are stale** — those edits are committed in `e234ac9b` (V04 §1, V05 §0, V16-10). At the **V26 read HEAD is still `e234ac9b`**, but `variant3d/scripts/main.gd` and `world3d.gd` now carry **uncommitted** I11-SEAM inserts with exact pre-seam `inbox/backup/{main,world3d}.gd.bak-COORD-I11` baselines (`main.gd:125,189-191,593-594,1112-1113`; `world3d.gd:118,144-145,220-224,624,706-707`), plus untracked donor scripts/tools/tests; `app/**` remains clean. `terrain_donor_world.gd` (I11-COMPOSER) does **not** exist yet, so the donor const points at a missing script until the composer lands. **Do not assert "port files clean / seam unapplied" as a permanent spec fact**; COORD must re-run `git status`, hashes and the seam anchors immediately before any dispatch. No gate result and no donor parity claim is implied. *(V26 C4)*

V43 live re-verification (read-only `git status --porcelain=v1`, `git rev-parse --short HEAD`, `git diff --stat`, `git rev-parse HEAD:<path>`, `Get-FileHash`, `Test-Path`): HEAD is **still `e234ac9b`**. The two I11-SEAM inserts remain **uncommitted and applied** in `main.gd`/`world3d.gd`; the live seam anchors were re-read at `world3d.gd:118` (const), `:144` (`terrain_backend = "legacy"`), `:220-224` (setter), `:624` (ternary), `:706-707` (stats). Backup hashes still equal V04/V11 baselines (`3859B605…` / `44EE96C0…`) and HEAD blobs still equal `30262b23…` / `638f33e6…`. `app/**` is still clean; `git diff --stat` additionally shows modified `docs/terrain_swarm_2026-11-26/CHARTER.md`, `SWARM_BOARD.md` and `spec/11_ASSET_CONVERSION.md`, and the V26 clause "`terrain_donor_world.gd` does not exist yet" is **now stale**: that composer file EXISTS as an untracked file at this read. Treat every git sentence here as point-in-time, never as a permanent clean/unapplied claim. *(V43 read-only re-verify; no git mutation, no parity claim)*

## 12.2 Ownership ledger (V11 — authoritative, one owner per file) [D]

Live tree at read: HEAD `e234ac9b`; `variant3d/` and `app/` clean; seam still
**unapplied** (`world3d.gd:108` only `TERRAIN_SCRIPT`, `:609` only
`terrain = _instantiate(TERRAIN_SCRIPT)`; `main.gd:587,1104` bare
`make_world3d()`).

**EDIT files (4):**
| File | Sole owner | Reserved backup | SHA-256 (at read) |
|---|---|---|---|
| `main.gd` (4 additive inserts) | COORD seam owner **I11-SEAM** | `bak-COORD-I11` | `3859B605…` |
| `world3d.gd` (const/vars/setter/ternary :609/stats) | same **I11-SEAM** | `bak-COORD-I11` | `44EE96C0…` |
| `tests/manifest.json` (append LAST, stage 3 only) | **I12** | `bak-I12` | `408F4C83…` (40 tests) |
| `config.gd` (stage 4 only, conditional) | **COORD-STAGE4** | `bak-COORD-STAGE4` | `160F08C0…` |

**19 NEW files + 11 generated asset entries**, one owner each. Canonical paths:
PLAN tool names win over A03 `*_new.py` aliases; output root
`variant3d/assets/terrain_new/**` wins over A06's `donor_derived/**`; I09 owns
props (not A06 N5); I10 owns `terrain_donor_shader.gdshader`; I07 owns the
V09/A06-N4 `terrain_donor_tiles.gd`; I12 owns `t_terrain_donor.gd`; I13 owns
A05's `terrain_qa_harness.py`.

**Second ownership hole closed:** the seam constant must point at a NEW COORD
composer `terrain_donor_world.gd` (A06 N1 / V05 §4.2) — assign to **I11-COMPOSER**
(same COORD owner) composing the disjoint I06/I07/I08/I09 modules. Without it
the seam loads a missing script.

**Edit-freeze:** no implementation worker may edit `main.gd`, `world3d.gd`,
`game.gd`, `world3d_terrain.gd`, `config.gd`, `manifest.json`, `app/**` except
the named owner. Dump contract is the existing
`{map_w, map_h, height, tileblock}` recipe plus additive `fields` (spec §01),
read-only on the sim.

## 12.3 Five rollout gates (A06 §gates)

1. Spec sections READY (cross-checked, contradictions resolved).
2. Decoder tools landed + byte-validated against donor.
3. Default-legacy new module composes and passes all existing gates.
4. Opt-in A/B capture; owner review; no parity claim without a real donor A/B.
5. Owner-approved default flip; only then retire the legacy path.

Structural invariants hold for both backends; no threshold lowered, no assertion
deleted.

## 12.4 Rollback (A06 + V04 — V04 supersedes the stale premise)

**V04 [O]:** HEAD is `e234ac9b`; **all port files are clean** — P06/A06's
"uncommitted Y08b/Y10/Y11" edits are already committed; only `docs/**` is
uncommitted. V04 recorded exact SHA-256 for 17 port files and the `.bak-Y08`,
`-Y08b`, `-Y10`, `-Y11`, `-Z08`, `-FOLD07`, `-B04` baselines; note
`.bak-Y10 == .bak-B01b` and `.bak-B04 == current world3d_terrain.gd`.

Landed machinery: Y08/Y08b final-authority collapse (`game.gd:2151-2166`),
collision-only gradient pass (`:1274-1310`), Y07 guards (`:2333-2345`), Z08
read-only MultiMesh props (`world3d_relief.gd:3-8,86-253`), committed C01
`terrainmesh1..4`.

Highest double-apply risk: the seam, now **applied once in the working tree at V26 read** (`main.gd` 4 inserts; `world3d.gd` const/vars/setter/ternary `:624`/stats) by the single COORD owner **I11-SEAM** with reserved suffix `COORD-I11` (V11 §2 E1/E2). Do **not** re-apply it; verify the two working-tree hashes against `.bak-COORD-I11` (`3859B605…`/`44EE96C0…`) and the HEAD blobs (`30262b23…`/`638f33e6…`) first. The Y08b/Y10/Y11 diffs are committed baselines and must never be re-applied either. `main.gd`+`world3d.gd` are the only seam files; default `"legacy"`. File-scoped `Copy-Item inbox/backup/<file>.bak-COORD-I11 <file>` with SHA checks; `git reset --hard`, `git checkout .` and `git clean` remain forbidden. *(V26 C4; hashes re-verified at V43 read)*

File-scoped `Copy-Item inbox/backup/<file>.bak-V04 <file>` with SHA checks.
**Forbidden:** `git reset --hard`, `git checkout .`, `git clean` (owner owns all
git operations). Verify hashes before applying, never double-apply.

## 12.5 Non-negotiable QA gates

variant selftest **29/29**, uitest **17/17**, `t_render_mode` PASS,
`assert_clean` CLEAN, `app/**` byte-identical, one Godot at a time via
`variant3d/tools/godot_runner.py` with unique `--id`.

## 12.6 QA harness (from A05)

Five layers (A05 §0):

1. **Determinism gate (hard).** Two runs at identical `(seed, generation-key
   tuple)` must be byte-identical on five `--dump-map` streams — `height` (f32
   bytes), `terrain`, `blocked`, `tileblock`, canonical-hashed prop/cluster/stamp
   set — at **64², 240², 320²**, zero tolerance. SHA-256 over raw decoded bytes
   (`main.gd:791-798`, `full_map_shot.py:191-227`).
2. **Structural gates S1–S7 (hard + advisory).** Height deciles, water/shore
   fractions, tile-id histogram, relief stamps, family counts, mine/field/forest
   counts. Numeric donor ranges are not yet in evidence, so the harness ships
   `--policy advisory` and only accepts `--policy red` after a signed donor spec.
   No fabricated bands; thresholds are `[D]` or `[I]`, never `[O]`.
3. **Visual A/B protocol.** The 12 donor stills in `C:\Users\Maxym.Oboyshev\
   Downloads\c3\` are third-party images of unknown build/camera/compression.
   Only statistical *direction of movement* on matched fractional ground ROIs is
   legitimate (C01:145,181,205-217; G21:80-105). `compare_shots.py` SSIM/MAD is
   legitimate **only** for candidate-vs-candidate determinism at a pinned camera,
   never donor parity. G0-a…e admissibility + R1–R8 region cards; metric never
   overrides the visual read (G21:241-250).
4. **Gate sequence + rollback.** Preflight → static → determinism → structure →
   visual → regression → COORD sign-off. Any hard FAIL, gate weakening, `app/`
   hash drift, blank capture or `timed-out|error|skipped` runner status ⇒ roll
   back to the legacy switch and restore from `inbox/backup/`.
5. **JSON schema** `terrain_qa_report/1` keeps labels, evidence ids, metric and
   visual fields separate and records `parity.status = "UNVERIFIED"`.

A05 submits zero Godot jobs; all runner commands are PLANNED for implementation
owners. Reconcile with P03's gate/capture inventory before promoting advisory → red.

## 12.7 Gate/capture baseline caveats (from P03) [O]

- All existing green gate JSONs are **stale** — must be regenerated with unique
  runner ids before they certify the fresh module.
- Most `variant3d/tools` capture scripts are byte-identical `app/tools` copies
  with **hardcoded `app/` paths**; fresh 240²/320² captures need explicit
  overrides or variant3d-local copies.
- Runner spool `variant3d/.godot_queue` is 607/607, pending 0, lock free, but
  **3 unacked failures** make a bare `assert_clean` DIRTY. They must be
  acknowledged **with reasons**, not deleted or silenced (V06 is preparing the
  exact remediation).
- No fresh 240²/320² baseline exists; `terrain_ab_metric.py` is SMOKE-only with
  no ARI. `compare_shots.py` remains restricted to self-determinism (A05 §3).

---
*Integrated by COORD from A05 + A06.*

