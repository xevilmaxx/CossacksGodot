---
id: BUILD-SKIN-02
title: "BUILD-SKIN-02 — regenerate the port skin data so peasant `construct` frames exist"
date: 2026-11-25
owner: BUILD-SKIN-02 (asset/data regeneration worker subagent)
status: DELIVERED__REGENERATED_OFFLINE__NO_RUNNER__NO_DONOR_COPY__NO_PARITY_CLAIM__NO_GIT_OPS
scope: "Two tracked files changed in the repo: variant3d/assets/models/skin/index.json and variant3d/assets/models/skin/peasant.json, plus this report. All 56 pre-regeneration skin JSONs backed up OUTSIDE the repo. No convert_skins.py, manifest, anim3d.gd, world3d_entities.gd, test, app/** or config edit. No Godot/runner/Blender; donor opened read-only bytes only; no donor binary executed or copied. No git operations of any kind."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1, no binary executed or copied)"
output: "docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_02.md"
labels: [observed, derived, UNVERIFIED]
governing_rule: "Cite donor path:line or path:offset; separate observed / derived / UNVERIFIED; never claim donor parity from data-level or motion evidence (DANIM-01 frontmatter :12; BUILD_ANIM_DIAG_01 frontmatter :12)."
verdict: "Converter re-run offline with the exact BUILD_SKIN_01 §6 command. peasant.json now carries actions.construct.frames == [186,188,191,193,196,198] and donor == 'data/animations/aaf/peaukr.aaf:17' (observed from regenerated JSON). Only peasant.json changed among the 55 per-sid skins; the other 54 are byte-identical. index.json changed only in actions_requested, the peasant entry and total_bytes. All 56 regenerated JSONs load cleanly; all original anim columns are byte-identical and the six new columns match read-only donor .oss frame values. This is a data-level export only: no runtime branch was fixed, no capture was run, no donor parity is claimed."
---

# BUILD-SKIN-02 — regenerate skin data so peasant `construct` frames exist

## 1. Context read (all read-only)

| # | Source | Used for |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/BUILD_SKIN_01.md` | prior converter edit, validation, hand-off command `:121`, scope `:7,173-175`, open Q `:147-155` |
| S2 | `docs/coord_swarm_2026-11-25/reports/BUILD_ANIM_DIAG_01.md` | root cause `:13,190-203`; expected frames `[186,188,191,193,196,198]` `:212,239,244`; shipped-skin gap `:153-168`; owner boundary `:211-213` |
| S3 | `variant3d/tools/convert_skins.py` (read in full, not edited) | `DEFAULT_ACTIONS` `:69-81` (now includes `construct`); output paths `:284-293`; `read_aaf` `:126-145`; `sample_frames` `:148-157`; per-sid write `:236-260`; `index.json` write `:310-326`; CLI/help `:46-50,279-288` |
| S4 | `python variant3d/tools/convert_skins.py --help` (read-only) | confirmed flags `--game`, `--manifest`, `--out`, `--frames-per-action`, `--actions`; no write on `--help` |
| S5 | fresh read-only donor bytes probe (temp, deleted) | verbatim `data/animations/aaf/peaukr.aaf:17` (§2) |

**Output paths confirmed:** input manifest = `variant3d/assets/models/manifest.json` (`--manifest`, converter `:284,291`); output directory = `variant3d/assets/models/skin` (`--out`, `:285,293`), which receives 55 per-sid `<sid>.json` files plus `index.json` (`:258-260,325-326`). There is no `manifest.json` *output* — the manifest is input-only. The generated data is under `variant3d/assets/models/skin/**` (this worker's exclusive ownership).

## 2. Donor truth — independently re-read (observed)

Probe opened `C:\Games\Cossacks 3\data\animations\aaf\peaukr.aaf` as bytes, decoded latin-1, split on `\r\n`, never executed or copied. Verbatim rows:

| Donor citation | Verbatim row | Derivation |
|---|---|---|
| `data/animations/aaf/peaukr.aaf:17` | `"construct",186,198,morph` | inclusive **186..198** = 13 frames; @ `.oss` fps 30 = 0.433 s (**derived**) |
| `data/animations/aaf/peaukr.aaf:3,4,20` | `"idle",64,113,morph`, `"idle0",64,113,morph`, `"unprepare0",64,65,morph` | context rows confirm the AAF line numbering used by `read_aaf` (`:133-142`) |

Supporting chain (carried from S1 §2 / S2 §2.1, **not** re-probed here): `gc_statetag_action_build = 1 shl 8` (`data/scripts/dmscript.global:13`) → `gc_anim_construct = 'construct'` (`dmscript.global:926`) selected at `data/scripts/lib/unit.script:10877`; binding `peaukr.prop:54` → `acl.lib:238-239` → `data/animations/acl/peasant.acl:2245-2252`. No range was hard-coded by this worker; `read_aaf` derives `first`, `last` and the `donor` citation per unit (converter `:218-227`).

## 3. Backup (outside the repo, before any write)

| Item | Value |
|---|---|
| Directory | `%TEMP%\opencode\quarantine\skins_before_buildskin02\` = `C:\Users\MAXYM~1.OBO\AppData\Local\Temp\opencode\quarantine\skins_before_buildskin02\` |
| Contents | all 56 generated JSONs (55 per-sid + `index.json`), copied with `Copy-Item` before the converter ran |
| Integrity | SHA-256 of each backup copy re-verified against the original pre-run hash manifest (`BEFORE_SHA256.txt`): **56/56 match, 0 mismatches** |
| Extra helper files in quarantine (not repo) | `BEFORE_SHA256.txt`, `AFTER_SHA256.txt`, `SNAPSHOT_BEFORE.json`, `SNAPSHOT_AFTER.json`, `snapshot.py`, `compare.py`, `verify_deep.py` |
| Key backups | `peasant.json` SHA-256 `7E0BB23BFC952E46EE4FF1F8255CD0D88A6172EF39CF1245B28CBA29614C6E1F`; `index.json` SHA-256 `FA3A247CA92F6F6E14AE7DC72F94A4BA99505D49D695519CFF87F19F7D589BAA` |

No donor file and no repo source file was backed up or copied; only generated JSON assets.

## 4. Command executed (step 3)

Exact command (from S1 §6 `:121` / converter usage `:46-50`), run once from the repo root with Python 3.14:

```
python variant3d/tools/convert_skins.py --game "C:\Games\Cossacks 3" --manifest variant3d/assets/models/manifest.json --out variant3d/assets/models/skin
```

| Metric | Value |
|---|---|
| Exit code | `0` |
| Runtime | `11132 ms` (~11.13 s), measured with `[System.Diagnostics.Stopwatch]` |
| stdout/stderr (combined) | `exported 55 skins, 7 skipped, 0 failed; total 3.72 MB -> variant3d\assets\models\skin` + first five entry lines + seven `SKIP <hull>` lines (verbatim below) |
| Output file count after | **56** (55 per-sid JSON + `index.json`), unchanged from before |
| Skips | `yacht, yachttur, fishboat, frigate, galley, battleship, xebec` — all `.osm/IDP2` hulls, same as before |
| Failures | **0** |

First entry line (verbatim): `peasant  k= 483 b=20 v= 577 frames=30 actions=idle,idle0,walk,death,attack0,construct   64393 B`.

No donor binary was run; the converter only opens donor `.oss`/`.aaf` files named by the manifest (converter `:4-6`). No Godot, runner, or Blender was invoked.

## 5. Verification (step 4)

### 5.1 Peasant `construct` entry (observed from regenerated JSON)

```json
"construct": {"first":186,"last":198,"kind":"morph",
              "donor":"data/animations/aaf/peaukr.aaf:17",
              "frames":[186,188,191,193,196,198]}
```

| Check | Expected | Result |
|---|---|---|
| `actions.construct.frames` | `[186,188,191,193,196,198]` | **PASS** (exact) |
| `actions.construct.donor` | `data/animations/aaf/peaukr.aaf:17` | **PASS** (exact) |
| `first` / `last` / `kind` | `186` / `198` / `morph` | **PASS** |
| `sample_frames(186,198,6)` (BUILD-SKIN-01 `:103`) | same six frames | **PASS**, matches exported |
| Frames union | old 24 ∪ new 6 = 30, sorted, no frame removed | **PASS** — added `[186,188,191,193,196,198]`, removed `[]` |
| Peasant entry `frame_count` | 24 → 30 | **PASS** |

### 5.2 Original actions unchanged / only `construct` added (derived, structural snapshot diff)

| Check | Result |
|---|---|
| Per-sid skins unchanged | **54 / 55** byte-identical |
| Per-sid skins changed | **1 / 55** — `peasant.json` only |
| `peasant.json` action_names | `['idle','idle0','walk','death','attack0']` → same **+ `construct` appended last** |
| All five pre-existing action sub-objects (`first`,`last`,`kind`,`donor`,`frames`) | **byte-identical** (re-serialised compact SHA-256 per action compared) |
| New action keys in every changed skin | exactly `{'construct'}`, no other key added or removed |
| `verts` / `weights` SHA-256 | unchanged in `peasant.json` |
| Original `anim` frame columns | **byte-identical** at every one of the 24 old frame positions (0 mismatches across 20 bones × 24 frames) |
| New `anim` columns (6 × 20 bones) | **match read-only donor** `C:\Games\Cossacks 3\data\actors\units\peaukr.oss` frame values via `read_oss` + `r6` (0 mismatches) |
| JSON corruption | `json.load` succeeded on **all 56** regenerated files (0 bad) |

The only non-action field that changed in `peasant.json` is `anim` (serialize hash), which is the direct and necessary consequence of inserting six new donor frame columns into the compact frame union — confirmed donor-grounded above. `bytes`/`k`/`fps`/`bones`/`v`/`oss_bytes` metadata unchanged.

### 5.3 `index.json` changes (derived)

| Field | Before → After |
|---|---|
| `actions_requested` | `[idle,idle0,walk,walk0,death,attack0,attack1]` → `[...,'construct']` |
| `count` | `55` → `55` (unchanged) |
| `skipped` / `failed` | unchanged (7 / 0) |
| `total_bytes` | `3712594` → `3720747` (+8153) |
| entry-level changes | only `peasant`: `actions` (+construct), `frames` (24→30), `frame_count` (24→30), `bytes` (56240→64393) |
| other 54 entries | unchanged |

No other skin JSON gained `construct`. This is consistent with donor truth: `construct` is present in the peasant AAF with an in-range clip; sids whose AAF lacks it are skipped by converter `:216-217` (and sids with an out-of-range clip by `:219-220`).

## 6. Before → after hashes (SHA-256, tracked files changed by this worker)

| File | Before | After |
|---|---|---|
| `variant3d/assets/models/skin/peasant.json` | `7E0BB23BFC952E46EE4FF1F8255CD0D88A6172EF39CF1245B28CBA29614C6E1F` | `D5372047862AF9CB4D4AFC7B92E143AA8912FBE47E80D3A5A7C1A0EB627D4F4F` |
| `variant3d/assets/models/skin/index.json` | `FA3A247CA92F6F6E14AE7DC72F94A4BA99505D49D695519CFF87F19F7D589BAA` | `0EF8085D09A2908B3777E3D3B3FA5DFBFB2C9C1F713830D96B0765A02FE4A137` |

File sizes: `peasant.json` 56240 → 64393 B; `index.json` 33944 → 34018 B. The other 54 per-sid JSON hashes are unchanged. Full before/after hash manifests are in the quarantine folder (`BEFORE_SHA256.txt`, `AFTER_SHA256.txt`).

`git status --porcelain -- variant3d/assets/models/skin` showed exactly ` M index.json` and ` M peasant.json` (`git diff --stat`: 2 files, 2 insertions, 2 deletions — each file is one compact JSON line).

## 7. Files changed unexpectedly / incidental artifacts

- **No unexpected tracked file changed.** The converter wrote only into `--out`; no manifest, tool, script, test or `app/**` file was modified by this worker. No hand-editing of generated JSON was performed.
- **One incidental ignored cache artifact:** the read-only verification import `from convert_skins import read_oss, r6` refreshed `variant3d/tools/__pycache__/convert_skins.cpython-314.pyc` (timestamp 2026-11-25 12:07:05). `git check-ignore -v` confirms `__pycache__/` is ignored at `.gitignore:41`, the file is **untracked** (`git status --porcelain --ignored` → `!!`), and no source file was touched. It is a regenerable Python bytecode cache, not a delivered asset; it is disclosed here for completeness. To avoid re-creating it, no further converter imports were used.
- No donor file was written, executed, unpacked, or copied into the repo.

## 8. Remaining runtime integration and discriminating capture (owner boundaries)

This ticket is **data-only**. It makes the frames available; it does not make the runtime ask for them.

- **Rank-1 branch still outstanding:** `variant3d/scripts/world3d_entities.gd:_unit_action()` (`:1009-1016`) has no `order.type == "build"/"repair"` → `construct` branch. **NATION-MODEL-01 owns `world3d_entities.gd`** (`SWARM_BOARD.md:297`, session `ses_dedad36a5ffeWEolNmXHw5gRb0`; backup artifact `inbox/backup/world3d_entities.gd.bak-NATIONMODEL01`). This worker did not edit that file and makes no claim about the branch's current state beyond what is recorded elsewhere (`BUILD_ANIM_DIAG_01 §5`, `BUILD_ANIM_01.md:107`).
- `variant3d/scripts/anim3d.gd`: **no change required** — `AAF_ACTIONS["construct"] = [186,198,17,"morph"]` (`:86`) and `_action_range_for` (`:918-934`) already resolve the new per-sid action. `_nearest_exported_frame` (`:907-912`) will now find real construct frames instead of snapping to death 149 / attack0 237. The shipped `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = "UNVERIFIED"` labels remain exactly as generated.
- **Discriminating capture (recipe only, NOT run here):** per `BUILD_ANIM_DIAG_01 §6`, drive `pose_for(...,"construct", f/30)` for `f in [186,188,191,193,196,198]`; expect `pose.frame` to equal those six values (six distinct vertex-buffer hashes), never `{149,237}`, `pose_source == "donor_flat_root_morph"`, `visual == "UNVERIFIED"`. At sync level, a build-order peasant should show `rendered_actions["construct"] >= 1`, zero builder idle frames, batch keys containing `|aconstruct|`, and an advancing `build_stage_suffix`. This capture remains **UNVERIFIED** and is the gate that distinguishes "action string changed but skin export missing" from a real build sequence.
- Tool (hammer `.oss`, `unit.script:7008`), `buildsmoke` PFX, stage OBJs, and loop/blend policy remain out of scope and **UNVERIFIED**.

## 9. Explicit no-parity claim

**No donor parity, visual equivalence, or rendered-frame claim is made.** The evidence here is data-level: regenerated JSON matches the donor AAF row and donor `.oss` frame values under the existing flat-root skin math. Deformation stays `PORT APPROXIMATION — NOT DONOR PARITY`; `visual = "UNVERIFIED"`. The `<6>` frame count is a deterministic donor-order decimation (`bake_sprites.py:145-152`), not a claim of motion fidelity. No capture, no runner, no Godot run was performed by this worker. Loop/one-shot engine semantics, hammer/tool presentation, smoke PFX, 8-azimuth equivalence and bind/quaternion convention remain **UNVERIFIED**.

## 10. Open questions

1. Who runs the discriminating capture in §8, and when (depends on the NATION-MODEL-01 build branch landing)? **UNVERIFIED.**
2. Should `workfood`/`workwood`/`workstone` also be exported (BUILD_SKIN_01 open Q2)? Deliberately **not** included in this minimal regeneration.
3. Only `peasant.json` gained `construct`; if other sids are expected to build (e.g. nation variants), their AAFs must be checked by their own data owners — none had an in-range `construct` clip in this run.
4. The ignored `__pycache__` timestamp change (§7) is disclosed, not reverted; reverting a regenerable bytecode cache was judged riskier than leaving it. Owner decision if a byte-identical cache is required.
5. No donor-parity or visual-equivalence evidence was produced; none is claimed.

## 11. Summary

- **Donor citations (observed, fresh read):** `data/animations/aaf/peaukr.aaf:17` = `"construct",186,198,morph` → 186..198 inclusive, 13 frames @30 fps = 0.433 s (derived); chain `dmscript.global:13,926` / `unit.script:10877` / `peasant.acl:2245-2252` carried from S1/S2.
- **Command:** exact S1 §6 command, exit 0, 11132 ms, 55 exported / 7 skipped / 0 failed, 56 output files.
- **Key result:** `peasant.json` `actions.construct.frames == [186,188,191,193,196,198]`, `donor == "data/animations/aaf/peaukr.aaf:17"` — both **PASS**.
- **Diff scope:** 54/55 per-sid skins byte-identical; only `peasant.json` gained `construct`; its five original actions and 24 original anim columns are byte-identical, six new columns match donor `.oss`; `index.json` changed only in `actions_requested`, peasant entry and `total_bytes`; all 56 JSONs load cleanly.
- **Backup:** all 56 pre-run JSONs copied to `%TEMP%\opencode\quarantine\skins_before_buildskin02\`, 56/56 hash-verified.
- **Remaining:** runtime build→construct branch owned by NATION-MODEL-01 (`world3d_entities.gd`); discriminating capture still to be run by its owner; no `anim3d.gd` change required.
- **Labels:** `PORT APPROXIMATION — NOT DONOR PARITY`, `visual = "UNVERIFIED"` retained; hammer/smoke/stage/loop **UNVERIFIED**; **no parity claim**.
- **No git operations** (no add, commit, checkout, stash, reset or any other git mutation) were performed by this worker; only `git status`, `git diff --stat`, `git check-ignore` and `git ls-files` were used read-only.

*End of BUILD-SKIN-02 report.*
