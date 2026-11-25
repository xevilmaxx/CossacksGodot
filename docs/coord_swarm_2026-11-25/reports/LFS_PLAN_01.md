---
id: LFS-PLAN-01
task: "Decide the Git-LFS / clone-size path for the new Winter atlas without touching git"
agent: "COORD (read-only analysis worker)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_GIT_OPERATION__NO_FILE_EDIT__NO_RUNNER_JOB
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/LFS_PLAN_01.md"
scope: "One report only. Read-only filesystem + git/LFS inspection. No git add/commit/checkout, no edit to any repo file, no runner job, no donor access."
no_repo_change: true
labels: [observed, derived, inferred, UNVERIFIED]
visual_parity_claim: false
---

# LFS-PLAN-01 — Winter atlas transport decision (plan only, no git action)

## 0. Label key

- **observed** — read directly this lane from a file, a git object, a command's literal output, or a measured byte/hash.
- **derived** — deterministic consequence of observed values (e.g. a `*.png` glob covers the Winter PNG; a byte slice sums to the source size).
- **inferred** — interpretation with a stated caveat; no runtime or network execution backs it.
- **UNVERIFIED** — cannot be proven from readable data (remote LFS availability, fresh-clone behaviour, visual parity, final artifact naming).

All git/LFS commands below were **read-only queries** (`ls-files`, `check-attr`, `cat-file`, `show :path`, `status`, `check-ignore`, `lfs version`, `lfs ls-files`, plus Python `stat`/`hashlib`). No mutating git command was run.

## 1. Sources

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SP_04_winter_atlas.md` | Winter PNG 124,463,306 B / `5d0dd8f3…`; old 3-line pointer `6b251045…` / 74,986,953 B; §7.1 LFS divergence, §7.2 path mismatch, §8 LFS/clone warning (observed-in-source) |
| S2 | `docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md` | Summer PNG LFS-tracked (134-B pointer), split parts are plain blobs, fallback `single → split → array`, clone-size/LFS caveats §6–§7 (observed-in-source) |
| S3 | `docs/coord_swarm_2026-11-24/reports/V791_dual_mode_atlas.md` §9.3 | "uncommitted **or** LFS" caveat, parts+manifest survive a clone without the big PNG, automatic fallback (observed-in-source) |
| S4 | `docs/coord_swarm_2026-11-25/decomp/README.md` | Donor decomp lane documentation, read as instructed: **no relevance to transport**. It is a documentation-only lane with no Git/LFS content; no decision input (observed) |
| S5 | `.gitattributes` (read-only) | line 1: `*.png filter=lfs diff=lfs merge=lfs -text` (observed) |
| S6 | read-only `git` / `git lfs` queries + `python` stat/hash | §2 evidence table (observed) |
| S7 | `variant3d/scripts/tile_atlas_loader.gd:66-86,99-118,174-200` and `docs/coord_swarm_2026-11-25/reports/SP_05_loader_override.md:127-135` | `SPLIT_MANIFEST` fixed to Summer; `manifest_path` override only reaches `_load_grid()`/`_load_array()`; fallback chain unchanged (observed) |
| S8 | `variant3d/tools/pack_tile_atlas_split.py:53,335-338` | existing splitter hard-codes the Summer `SOURCE`; only `--check` / `--measure-zip` flags (observed) |

## 2. Read-only git / attribute / file evidence

Repo root: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.
Path examined: `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png`.

| Fact | Exact evidence | Label |
|---|---|---|
| `.gitattributes` has one LFS rule, a `*.png` glob | `.gitattributes:1` = `*.png filter=lfs diff=lfs merge=lfs -text` | observed |
| That rule covers the Winter PNG | `git check-attr filter -- <winter png>` → `<winter png>: filter: lfs` | observed |
| Index entry is a regular-mode blob, not a directory/symlink | `git ls-files -s -- <winter png>` → `100644 8fa9d598bd3c9e777cee0122445210360a0fef30 0 <winter png>` | observed |
| Index blob is a pointer-sized blob | `git cat-file -s 8fa9d598bd3c9e777cee0122445210360a0fef30` → `133` | observed |
| Pointer content is the **old** object | `git show :<winter png>` → `version https://git-lfs.github.com/spec/v1` / `oid sha256:6b251045f815ff8379c8db2ad74d10d12e1891d688280c58604b60d862d1a814` / `size 74986953` | observed |
| Working-tree file is the **new** full-size PNG | Python 4 MiB chunked hash + `stat`: `124463306` bytes, SHA-256 `5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` (both methods agree) | observed |
| Working tree diverges from index; manifest is new | `git status --porcelain -- <winter png> <winter manifest>` → ` M <winter png>` / `?? <winter manifest.json>` | observed |
| Neither path is ignored | `git check-ignore -v -- ...` → no output (exit 1) | observed |
| Git LFS is available | `git lfs version` → `git-lfs/3.4.1 (GitHub; windows amd64; go 1.20.11; git 0898dcbc)` | observed |
| LFS tracks the old Winter OID in the index | `git lfs ls-files --all` tail: `a1f123a107 * .../tile_index_atlas.png`; `6b251045f8 - .../tile_index_atlas_winter.png` (dash marker as printed) | observed |
| Both old and new LFS objects exist **locally** at full size | `.git/lfs/objects/6b/25/6b251045…` = 74,986,953 B; `.git/lfs/objects/5d/0d/5d0dd8f3…` = 124,463,306 B; `.git/lfs/objects/a1/f1/a1f123a1…` = 179,912,941 B | observed |
| Split parts are **not** LFS-filtered; Summer PNG **is** | `git check-attr filter -- atlas_parts/tile_index_atlas.part000 …/tile_index_atlas.png` → `part000: filter: unspecified`; `tile_index_atlas.png: filter: lfs` | observed |
| Winter regeneration inputs are tracked | `git ls-files -s`: `build_winter_atlas.py` blob `2fae10f2…`, `winter_aliases.json` blob `141a62b0…`, `presets_summer.json` blob `8e270232…` | observed |
| Split fallback manifest is Summer-only and has no Winter counterpart | loader `:70` `SPLIT_MANIFEST := "res://assets/terrain/atlas_parts/split_manifest.json"`; recursive glob `atlas_parts/*winter*` → no files | observed |
| The new OID does **not** appear in any index pointer yet | `git show :<winter png>` still reports `6b251045…`; `git lfs ls-files --all` lists only `6b251045f8` for the Winter path | observed |

**Derived consequences**

- Because `.gitattributes:1` matches `*.png`, an owner-run `git add` on the working-tree PNG will run the LFS clean filter and rewrite the index pointer to the **new** oid/size automatically; no `git lfs track` edit is needed (derived from S5 + S6).
- The new pointer would be ~134 B (same field widths as Summer's observed 134-B pointer; one byte longer than today's 133-B pointer because `124463306` has one more digit than `74986953`) — **derived, not measured** (it was not staged).
- Git-side clone growth from option (a) is ≈ +1 B; LFS-side transfer growth is exactly **124,463,306 B** when LFS smudge is enabled (derived from S2 + S6).
- No Winter split parts exist, and `SPLIT_MANIFEST` is a fixed constant; therefore a failed Winter `single` load falls back to reassembling the **Summer** atlas, i.e. wrong-season art, with only a `push_warning` (derived from S7 + S6; **runtime UNVERIFIED** — no runner job was launched).
- Two equal Winter parts of **62,231,653 B each** would sum exactly to 124,463,306 B and both sit below GitHub's ~100 MB per-file ceiling (derived arithmetic). The existing splitter cannot produce them without a code change (S8).

**UNVERIFIED**

- Whether the remote GitHub LFS endpoint holds `5d0dd8f304…` (or the old `6b251045…`). No network operation was performed. The object's presence in the local cache does **not** prove remote presence.
- Why `git lfs ls-files --all` prints `-` for `6b251045f8` although the object file is present locally at full size (marker semantics not probed).
- Any genuine fresh-clone run, any GPU A/B, and any visual parity.

## 3. Option comparison

Ranking is by the four requested criteria. "Rank" is the overall recommendation order; trade-offs are explicit.

| Option | Git clone bytes added | GitHub ~100 MB/file | Loader fallback behaviour | Reproducibility | Rank |
|---|---|---|---|---|---|
| **(a) LFS pointer with the NEW oid** `5d0dd8f3…` / 124,463,306 B | ≈ **+1 B** in the Git object store (pointer replaces pointer); **+124,463,306 B** only in the LFS download on an LFS-enabled clone | **Pass** — ~134-B pointer in-tree; full PNG lives in LFS | Correct Winter art when the LFS object is smudged (`single` succeeds). If the pointer is not smudged, `single` fails and falls to fixed Summer `split` → **wrong season**, warning only (derived) | **Best**: exact OID pinned by the pointer, full object already in local cache, SP-04 verified deterministic regeneration to the same SHA-256. Remote availability is the one caveat | **1 — recommend** |
| **(c) Leave local PNG (+manifest) untracked, document regeneration** | **0 B** — no new repo object at all | **Pass** — nothing oversized is committed | Fresh clone has no Winter PNG → `single` fails → fixed Summer `split` → **wrong season** until the operator regenerates locally (derived) | Weakest in-repo: no committed OID/manifest pin; depends on an operator running the tracked tool. Tool determinism is observed (SP-04), inputs are tracked (S6), so it is reproducible **if** the step is followed | **2** (best clone size, but mandatory manual step) |
| **(b) Split Winter into ordinary-blob parts like Summer** | **+124,463,306 B on every clone**, LFS on or off; no LFS transfer | **Pass** if each part <100 MB (e.g. 2 × 62,231,653 B) | **Still wrong season today**: fixed `SPLIT_MANIFEST` points at Summer parts, and no Winter split manifest/parts exist. Needs a new loader hook (`split_manifest_path`) before fallback benefits Winter (derived) | Good in-repo: lossless byte slices, reassembly SHA-256 can be pinned in a committed manifest (pattern verified for Summer by S2) | **3** (highest permanent clone cost + requires code changes) |

### 3.1 Option (a) — exact steps for the **owner only** (NOT run by this lane)

Run from the repo root. Step 3 is a verification read, not a mutation.

```powershell
# One-time per machine; safe to re-run.
git lfs install

# Stage the new PNG and its manifest. The existing *.png rule in .gitattributes
# converts the PNG into a pointer with the NEW oid automatically.
git add variant3d/assets/terrain/atlas/tile_index_atlas_winter.png variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json

# Verify the staged pointer before committing. Expect:
#   oid sha256:5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb
#   size 124463306
# If it still says 6b251045... / 74986953, the add did not update the pointer.
git show :variant3d/assets/terrain/atlas/tile_index_atlas_winter.png

# Owner's commit and push (COORD does NOT do this).
git commit -m "Track Winter tile atlas via Git LFS (oid 5d0dd8f3)"
git lfs push --all origin
git push origin <branch>
```

Notes: `git lfs push --all origin` must come **after** the commit, because `--all` reads refs and the staged-only pointer is not yet in a ref. A normal `git push` also triggers the git-lfs pre-push hook and uploads needed objects; `git lfs push --all origin` is the belt-and-braces form when remote availability is unknown. Do **not** run `git lfs track "*.png"` — `.gitattributes:1` already covers it (derived from S5/S6).

Fresh-clone verification (owner/operator):

```powershell
git lfs install                       # BEFORE the clone
git clone <url>
cd CossacksGodot
git lfs pull                          # or: git lfs fetch --all
Get-Item variant3d\assets\terrain\atlas\tile_index_atlas_winter.png | Select-Object Length
Get-FileHash variant3d\assets\terrain\atlas\tile_index_atlas_winter.png -Algorithm SHA256
```

Expect `Length = 124463306` and hash `5D0DD8F3…3BADB`. A 133/134-byte file is the pointer, not the image — in that state a Winter capture will silently fall back to the Summer `split` atlas (derived, runtime UNVERIFIED).

### 3.2 Option (b) — exact steps (requires a new tool and a loader change by other owners)

The git portion is shown for completeness; the preparatory code does **not** exist yet and COORD did not create it.

1. Write (or parameterise) a Winter splitter. The existing tool is hard-wired to the Summer source (`pack_tile_atlas_split.py:53`) and has only `--check` / `--measure-zip` (`:335-338`), so it cannot emit Winter parts as-is (observed).
2. Produce two lossless slices of 62,231,653 B each plus a Winter split manifest recording `source.sha256 = 5d0dd8f304…`, part sizes/hashes and `reassembly.order`.
3. Add a loader config key for the split manifest (or make `SPLIT_MANIFEST` season-aware). Currently `:70` is a fixed const and `manifest_path` reaches only `_load_grid()`/`_load_array()` (observed, S7). **This is a code edit outside COORD's scope.**
4. Only then, owner-run:

```powershell
git add variant3d/assets/terrain/atlas_parts_winter/<part000> variant3d/assets/terrain/atlas_parts_winter/<part001> variant3d/assets/terrain/atlas_parts_winter/<manifest>.json
git commit -m "Add Winter atlas split parts"
git push origin <branch>
```

No LFS command is required for parts: `git check-attr filter` on `.part000` is `unspecified` (observed). Until step 3 lands, this option gives the clone cost without correct Winter fallback (derived).

### 3.3 Option (c) — exact steps (documentation-only)

```powershell
# After a fresh clone, before any Winter capture:
python variant3d/tools/build_winter_atlas.py
python variant3d/tools/build_winter_atlas.py --check
```

Then verify 124,463,306 B / `5d0dd8f3…` locally. Do **not** run `git add` on `tile_index_atlas_winter.png` or its manifest. The tool and its alias/preset inputs are already tracked (S6). The manifest path must be added to the SP-6 BIOME table as the local-generated file; a clone without that step renders Summer art through the split fallback (derived).

## 4. Path-name mismatch (independent of the LFS choice)

SP-04 §7.2 (and SP-05 §7) report that the landed renderer/test constants use `tile_index_winter_atlas.*`, while the actual artifacts are `tile_index_atlas_winter.*`:

- `variant3d/scripts/world3d_terrain.gd:269-270`
- `variant3d/tests/t_season_overlay.gd:59-60` (also `SP_08_season_test.md:157`)
- SP-05 §7 expects `tile_index_winter_atlas.manifest.json` + PNG.

**This lane did not re-read those constant files; the mismatch is observed-in-source, current-file re-check UNVERIFIED.** The LFS decision does **not** affect it: Git LFS changes transport only, never the filename. Whichever option is chosen, SP-6 must align the constants to `tile_index_atlas_winter.*` (or the artifacts must be renamed). If the mismatch is left in place, even a perfectly smudged LFS Winter PNG will not be found by the renderer — a missing path that falls back to Summer art regardless of option (a)/(b)/(c) (derived).

## 5. Recommendation

**Choose option (a): keep the path LFS-tracked and update the pointer to the new oid `5d0dd8f304…` / 124,463,306 B, using the owner-run commands in §3.1.** Rationale:

1. It is the only option that keeps the per-file ceiling satisfied **and** pins the exact Winter bytes in the repository, with near-zero Git clone growth.
2. The full object is already in the local LFS cache at the correct size/hash, so no local re-hash or re-generation is needed; only the pointer and remote upload are outstanding.
3. It matches the already-verified Summer precedent (ATLAS-01 §6.1) and requires no code edit by COORD, SP-5 or SP-6.
4. Its one real risk — a clone that gets a pointer instead of the image — is mitigated by the documented `git lfs install` / `git lfs pull` / size+SHA check in §3.1, and must be called out to SP-8 as a capture-hygiene gate: record the loaded atlas path and mode before comparing Winter frames.

Hold option (c) as the fallback if the owner prefers zero clone growth: it is operationally viable because the deterministic tool and its inputs are tracked, but it makes a manual regeneration step mandatory on every fresh clone. Option (b) should only be chosen if in-repo reproducibility is valued above clone size **and** another owner implements a season-aware split-manifest hook; until then it adds 124.5 MB to every clone without fixing Winter fallback.

**Safety note:** COORD did not stage, commit, push, checkout or otherwise change git state, and did not edit any repository file. The only file written by this lane is this report.

## 6. Open questions (UNVERIFIED — do not guess)

1. Does the configured GitHub LFS endpoint hold `5d0dd8f304…`? Local cache presence is proven; remote presence is not. If absent, `git lfs push --all origin` (or a normal push hook) must upload it.
2. What does the `-` marker in `git lfs ls-files --all` mean for `6b251045f8` given that the object exists locally at full size? Not probed.
3. Why does the old LFS object `6b251045…` (74,986,953 B) differ in bytes from the regenerated `5d0dd8f3…` (124,463,306 B)? SP-04 §7.1 labels this UNVERIFIED; the old object's provenance was not investigated here.
4. Has the `single → split → array` chain ever run in a genuine fresh clone with the Winter path wired? No artifact exists; SP-5 job 409 was `--check-only` and V7-91 job 250 simulated a missing file via `single_atlas_path` (second-hand).
5. Will SP-6 align the `tile_index_winter_atlas.*` constants to `tile_index_atlas_winter.*`, or rename the artifacts? Final naming UNVERIFIED.
6. Should the Winter manifest be committed as a regular blob alongside the LFS pointer (it is currently untracked, 79,837 B, SP-04 §5)? Recommended yes, but it is the owner's call.
7. Any GPU/visual parity between Summer and Winter atlases — no A/B was run; no parity claim is made.

## 7. Summary

- **Observed:** the Winter PNG is present at 124,463,306 B / SHA-256 `5d0dd8f304…3BADB`, while the git index still holds a 133-B pointer to old oid `6b251045…` (74,986,953 B); `*.png` in `.gitattributes:1` applies `filter=lfs` to this path; git-lfs 3.4.1 is installed; both old and new LFS objects exist locally at full size; the manifest is untracked; no Winter split parts exist and the loader's split manifest is fixed to Summer.
- **Derived:** staging the PNG will produce a ~134-B pointer with the new oid; option (a) adds ≈1 B to the Git store plus 124.46 MB of LFS transfer, option (b) adds 124.46 MB of permanent regular-blob clone weight, option (c) adds 0 B; any failed Winter `single` load currently falls back to Summer art through the fixed `split` mode.
- **Inferred:** option (a) is the best balance of clone size, GitHub-limit compliance, correct fallback when LFS is honoured, and byte-exact reproducibility; the path-name mismatch is orthogonal to transport.
- **UNVERIFIED:** remote LFS availability, dash-marker semantics, fresh-clone behaviour, old-object provenance, final naming, visual parity.

**No git operation and no repository file change were made by this task. Only `docs/coord_swarm_2026-11-25/reports/LFS_PLAN_01.md` was written.**

*End of LFS-PLAN-01.*
