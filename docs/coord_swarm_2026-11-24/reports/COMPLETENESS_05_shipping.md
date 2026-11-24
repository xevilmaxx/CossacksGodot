# COMPLETENESS_05 — Shipping hygiene of the 3D variant (2026-11-24)

**Agent:** COMP-05 · **Mode:** READ-ONLY audit (no Godot launches, no git commands, no edits outside this report).
**Evidence convention:** `path:line`, job id / result dir, or a filesystem snapshot (including direct reads of `.git/index`, `.git/lfs/objects`, `.gitignore`, `.gitattributes` — file reads, not git operations). Earlier claims are treated as UNDONE until verified in current state.

**Bottom line:** the functional gate artifacts are green and the 180 MB atlas is LFS-backed with verified split parts, but the shipping story has four real hygiene defects: (1) a hard GitHub-size dependency on LFS, (2) an unacknowledged variant queue that would make a variant clean gate DIRTY, (3) stale status/README statements, and (4) unimported PNG masks + tracked probe leftovers. No 2D gate regression was found.

---

## 1. Big files under `variant3d/` (filesystem `Sort-Object Length -Descending`)

Top 10 exact byte sizes (full paths relative to repo root):

| # | File | Bytes | > GitHub ~100 MB? | Ignore / LFS / manifest status |
|---|---|---:|---|---|
| 1 | `variant3d/assets/terrain/atlas/tile_index_atlas.png` | **179,912,941** | **YES** | Not ignored by `.gitignore`; `.gitattributes:1` applies `filter=lfs diff=lfs merge=lfs -text` to all `*.png`; LFS object present with matching SHA; `split_manifest.json:12-19` marks `RESTORED__DEFAULT_MODE_SINGLE__KEEP_UNCOMMITTED_OR_LFS` |
| 2 | `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part000` | 90,000,000 | No (85.8 MiB; equals manifest `part_max_bytes`) | Not LFS (extension is `.part000`, not `.png`); not ignored; tracked in `.git/index`; manifest `split_manifest.json:20-37`, SHA verified |
| 3 | `variant3d/assets/terrain/atlas_parts/tile_index_atlas.part001` | 89,912,941 | No | Same as above; SHA verified |
| 4 | `variant3d/.godot/imported/pie.ogg-00caeb0cc93dafac0222bb019393c75a.oggvorbisstr` | 15,764,555 | No | Runtime import cache; ignored by `.gitignore:88` (`variant3d/.godot/`); not in `.git/index` |
| 5 | `variant3d/assets/sounds/pie.ogg` | 15,680,184 | No | Donor audio; trackable (private-use only, `variant3d/CREDITS.md` / README:220-224) |
| 6 | `variant3d/.godot/imported/sco.ogg-f84a48fabf0bcddba654a2081b171d5d.oggvorbisstr` | 15,589,746 | No | Ignored import cache (`.gitignore:88`) |
| 7 | `variant3d/assets/sounds/sco.ogg` | 15,175,213 | No | Donor audio |
| 8 | `variant3d/.godot/imported/pol.ogg-2839bf5439c83d9d670d7018068c7aae.oggvorbisstr` | 14,555,207 | No | Ignored import cache |
| 9 | `variant3d/assets/sounds/pol.ogg` | 14,481,355 | No | Donor audio |
| 10 | `variant3d/.godot/imported/den.ogg-301bec5cbbd9601b1aa17372e91a6e42.oggvorbisstr` | 13,549,927 | No | Ignored import cache |

Context: `variant3d/` totals **12,765 files / 4,263,091,818 bytes**; `variant3d/assets/sounds/` alone is 295,623,846 B. Only file #1 breaches GitHub's per-file limit.

### 1a. Atlas / LFS verification (observable evidence)

| Check | Result | Evidence |
|---|---|---|
| Atlas is a real PNG, not an LFS pointer in the working tree | Header `89 50 4E 47 0D 0A 1A 0A`; 179,912,941 B | byte read of `variant3d/assets/terrain/atlas/tile_index_atlas.png` |
| SHA-256 matches split manifest | `a1f123a1…84dcfbd` for atlas; parts `019f0f9d…525f` / `295a527c…ba1be` match manifest exactly | `Get-FileHash` vs `split_manifest.json:15,27,34,65-69` |
| LFS configured and object stored locally | `.gitattributes:1`; `.git/config` has `[lfs]` and an LFS remote; `.git/lfs/objects/a1/f1/a1f123…` is exactly 179,912,941 B | filesystem reads |
| Atlas path present in git index | `.git/index` contains `variant3d/assets/terrain/atlas/tile_index_atlas.png` | filesystem read of `.git/index` (no git command) |
| LFS pointer blob itself | **NOT directly verified** — the object lives in a pack, and no git plumbing was allowed; conclusion of LFS tracking rests on `.gitattributes` + matching local LFS object + index path. Mark as **HIGH-confidence inference**, not a direct observation. | same |
| Split parts are GitHub-safe regular blobs | 90,000,000 / 89,912,941 B; no matching objects in `.git/lfs/objects`; `.gitattributes` does not match `.partNNN` | `split_manifest.json:20-37`; filesystem checks |
| Fallback chain | `single → split → array` with warning; split reassembles to `user://`, never `res://` | `README.md:99-113`; `variant3d/scripts/tile_atlas_loader.gd:8-16,264-277,321-339`; `split_manifest.json:38-45` |

**Verdict:** the single atlas is acceptable **only** as LFS (or uncommitted). A clone without LFS objects still runs via `split`/`array`; if neither parts nor blocks are present, single mode soft-fails (`tile_atlas_loader.gd:270-271`).

---

## 2. Resource integrity

### 2a. `res://` path sample (all literal paths in `variant3d/scripts/*.gd`)

85 unique literal `res://` strings were extracted from 3D scripts; 73 resolve on disk. The 12 non-resolving strings are classified below — **none is a broken runtime load in the current 3D path**:

| Non-resolving string | Source | Classification |
|---|---|---|
| `res://assets/models/anim/buildings.json` | `variant3d/scripts/game.gd:1494-1496,1525-1527` | Legacy **flat fallback**; nested `buildings/buildings.json` exists. UNVERIFIED on legacy route only |
| `res://assets/models/anim/sco_units.json` | `variant3d/scripts/data.gd:266-268` | Legacy flat fallback; `land_units/sco_units.json` exists |
| `res://assets/models/glb/` | `variant3d/scripts/world3d_entities.gd:62,161-175,449-451` | Directory absent; guarded by `ResourceLoader.exists()`; stat reports `glb_available` honestly, OBJ is the live path (172 OBJ) |
| `res://...png`, `res://assets/ui/cursor_` | `world3d_terrain.gd` comment; `input_controller.gd:73` | Placeholder / format-string fragment, not a path |
| 7 × `res://shots/...` (`bench.json`, `final_fullmap_dump.json`, `foo.json`, `terrain3d_m06*.json/.png`) | `main.gd:1609`; `terrain3d_sandbox.gd:6-17,53` | Generated outputs / legacy sandbox, ignored by `.gitignore:91`; not shipped inputs |

Resolved spot-checks (exist): `scripts/data.gd`, `scripts/config.gd`, `scripts/world3d*.gd`, `shaders/water3d.gdshader`, `assets/models/skin/index.json`, `assets/models/anim/land_units/sco_units.json`, `assets/models/anim/buildings/buildings.json`, `assets/terrain/{structs/presets_summer.json,masks/manifest.json,patterns/donor_patterns.json,heightmap/splat_albedo.png,water_png/diffusewaves0.png}`, `assets/ui/icons.bmp`, `assets/sounds/btnclick.ogg`.

### 2b. `.import` coverage and bake exclusions

| Item | Count | Finding |
|---|---|---|
| PNG under `variant3d/` (excluding `.godot/`, `.import` cache, `shots/`) | 2,992 | 2,987 have `.import` |
| PNG **missing** `.import` | **5** | `assets/terrain/atlas/{tile_index_atlas.png,alpha.png,alphavert.png}` and the `alpha.png`/`alphavert.png` copies under `atlas_parts/` |
| OBJ under `assets/` | 172 | **172/172 have `.import`** — full coverage |
| `.gdignore` on 2D bake dirs | 5 present | `assets/models/anim/`, `assets/models/sprites/`, `assets/models/sprites_hi/` (0 B); `assets/terrain/decals/`, `assets/terrain/decals_dds/` (111 B: "raw donor DDS decals + orphaned .uid; runtime uses decals_png/*.png"). Matches `README.md:184,207-213` and `STATUS_WAVE7_PHASE2.md:128-129,203-214` |

The 5 unimported PNGs are read as **raw image bytes** via `Image.load()` (`tile_atlas_loader.gd:306-318`) rather than Godot resources, so their lack of `.import` is intentional in-editor. **Export risk (UNVERIFIED):** `variant3d/export_presets.cfg` uses `export_filter="all_resources"` with no `include_filter`, so raw PNGs without `.import` may be omitted from an exported PCK. No export was run (READ-ONLY), so this is flagged, not proven.

### 2c. Agent leftovers / stray files

| Path (all under `variant3d/`) | Evidence | Assessment |
|---|---|---|
| `tests/_v716_probe.gd` (1,798 B) + `.uid` | Exists; name present in `.git/index`; job `v716-attach-probe` (ticket 64) | **Tracked probe script** left in shipped tests tree |
| `tests/t_v766_jump_probe.gd.uid`, `t_v771_audio_tmp.gd.uid`, `v762_entity_feed_probe.gd.uid`, `_v768_pick_probe.gd.uid` | `.uid` exists, matching `.gd` absent; names present in `.git/index` | **Orphan `.uid` files, tracked** — stale Godot script IDs |
| `tests/results/v760_light_probe.json`, `v769_selfonly_probe.json`, `_v790_camera_probe.json` | Files exist and names present in `.git/index` | **Tracked probe result JSONs**; not matched by `.gitignore:92-94` (`*_dump*`, `temp_*`, `*_tmp.json`) |
| `.godot/imported/*.ctex*.tmp` (6 files, 0 B) | Under `variant3d/.godot/` | Ignored (`.gitignore:88`); harmless runtime debris |
| `assets/models/anim/buildings/rus_sta_s4.png.import~RF139ced6.TMP`, `rus_sto_dead.png.import401825162.tmp` | Files exist; not in `.git/index`; `.gitignore:46` is lowercase `*.tmp` and `:114-119` matches `.png.import` exactly | **Likely unignored temp/backup sidecars** (case/suffix inference; `git check-ignore` not used per scope) |
| `tools/__pycache__/*.pyc`, `tools/unit_bakers/__pycache__/*.pyc` | Many files | Ignored by `.gitignore:41-42` (`__pycache__/`, `*.py[cod]`); not in `.git/index` |
| `tests/_template_test.gd` | 1,279 B | Intentional template, not a probe |

---

## 3. Runner state (direct file reads; no runner commands, no Godot launches)

Both `status.json` files contain **only** a top-level `history` array — there is no `pending` or `lock` object inside either JSON. "No in-flight job" is inferred from empty `jobs/` directories and `now_serving == counter`.

| Field | `variant3d/.godot_queue/status.json` | `app/.godot_queue/status.json` |
|---|---|---|
| History entries | 257 | 249 |
| `ok` | 173 | 165 |
| `failed` (test-red; excluded from clean gate by D-13) | 65 | 75 |
| `timed-out` | 19 | 8 |
| `skipped` | 1 (n/a → 0) | 1 |
| `acknowledged` entries | **0** | **9** (8 timed-out + 1 skipped; tickets 1132/1135/1184/1205/1261/1268/1270/1292/1295) |
| Unacked `failed`+`timed-out`+`skipped` | **84 / 84 (100 % unacked)** | 75 unacked, all `failed` |
| Unacked **failure-status** jobs (`timed-out`/`error`/`skipped`) | **19 → variant clean gate would be DIRTY** | **0** → consistent with stored CLEAN |
| `jobs/` dir | empty | empty |
| `now_serving` / `counter` | `257` / `257` (no in-flight ticket) | `1343` / `1343` |
| Last entries | 254 `coord-final3-selftest` ok, 255 `coord-final3-uitest` ok, 256 `coord-final3-render-mode` ok | 1340 `coord-variant-final-app-selftest` **failed (unacked, transient)**, 1341 uitest ok, 1342 selftest-r2 ok |
| Timestamp basis | `created` epoch seconds; last = 1795532999.73 | last = 1795525749.91 |

Notes:
- Historical unacked probe/timeout failures are known and expected from swarm churn. They are reported honestly, not "fixed".
- A variant `assert_clean.py` **exists** (`variant3d/tools/assert_clean.py`, 10,377 B, in `.git/index`) with `variant3d/tools/CLEAN_GATE.md`. Its gate definition (as in the app copy) treats `timed-out`/`error`/`skipped` as DIRTY and excludes `failed`. Given 19 unacked timed-out jobs, running it today would yield DIRTY unless those tickets are acked. No stored variant CLEAN verdict was found.
- 2D clean gate: failure statuses are all acknowledged, so CLEAN remains valid despite 75 unacked `failed` (gameplay test-red) jobs.

---

## 4. Docs accuracy

### 4a. Root `README.md`

| Statement | Verdict | Evidence |
|---|---|---|
| Two launchers `launch.bat` / `launch_variant3d.bat`, `launch_3d.bat` shim, PATH → WinGet → Program Files resolution, extra args forwarded | **ACCURATE** | `launch.bat:1-30`, `launch_variant3d.bat:1-45`, `launch_3d.bat:14-31`; all three files exist |
| `variant3d/config.json → gameplay.render_mode: "3d"`; 2D copy inside variant via `"2d"` | **ACCURATE** | `variant3d/config.json` `gameplay.render_mode = 3d`; `main.gd` seams per job 256 |
| Atlas size 179,912,941 B, `single` default with `split`/`array` fallback; "leave uncommitted or use Git LFS" | **ACCURATE** | `README.md:99-113`; `split_manifest.json:12-19,71-77`; LFS evidence §1a |
| Final gate green: 2D 29/29 + 17/17, 3D functional with visual parity UNVERIFIED | **ACCURATE** | `README.md:82-83`; jobs 1341/1342, 254/255/256; `variant3d/tests/results/t_render_mode.json` `seam_missing=false` |
| "`24 inherited + 7 atomic 3D tests`" | **ACCURATE** | `variant3d/tests/manifest.json`: `tests` = 31 entries, including `t_terrain3d`, `t_camera3d`, `t_pick3d`, `t_entities3d`, `t_fx3d`, `t_fog3d`, `t_render_mode` |
| **"28-step sim self-test"** (two places) | **STALE** | `README.md:45` and `README.md:64` say 28, while `README.md:22`, `:82`, `app/selftest.json` (29 steps) say 29; must be 29 |
| "Godot 4.7" | **ACCURATE** | Gate stdout: `Godot Engine v4.7.2.stable.official` (results dirs 254-256) |
| Minor nuance: `t_render_mode` 10/10 includes `render_mode_default_2d` / `runtime_default_2d` | Not a contradiction — those check the **source fallback** `"2d"`, not `config.json` (`"3d"`) | `variant3d/tests/results/t_render_mode.json` checks array; `variant3d/config.json` |

### 4b. `docs/variant3d/STATUS_WAVE7_PHASE2.md`

| Statement | Verdict | Evidence |
|---|---|---|
| Authoritative final verdict: gates green (29/29, 17/17, render-mode PASS) | **ACCURATE** | `STATUS_WAVE7_PHASE2.md:11-30`; jobs 254/255/256 `ok`, result JSONs, `selftest.json` 29/29 and `uitest.json` 17/17 |
| Historic gate jobs 130/157/163/185/186/191/193/203/204/205/212/241/254-256 | **ACCURATE** — all `ok` in variant history (direct lookup) | `variant3d/.godot_queue/status.json` |
| "60 historical, unacked probe-iteration failures" | **STALE — now 84** (65 failed + 19 timed-out, none acked) | `STATUS_WAVE7_PHASE2.md:40`; §3 table |
| "no variant `assert_clean.py` exists, so a formal variant CLEAN verdict is not claimed" | **HALF-STALE** — tool **does** exist (`variant3d/tools/assert_clean.py`, in `.git/index`); "no formal variant CLEAN claimed" remains correct because 19 timed-out jobs are unacked | `STATUS_WAVE7_PHASE2.md:41-42`; `variant3d/tools/CLEAN_GATE.md` |
| Badge `final--variant--gate-pending-orange` and TL;DR "final variant gate has not been run" (`:76`, `:92`) | **STALE / reader trap** — contradicts the authoritative verdict at `:11-59`; appears outside the clearly-labelled historical snapshot | `STATUS_WAVE7_PHASE2.md:11,76,80-92,114,162-163` |
| "2D gates … last 1289/1290" | **STALE** — latest are 1341 (uitest ok) / 1342 (selftest-r2 ok); 1340 transient failed | `STATUS_WAVE7_PHASE2.md:107,249-251`; app history |
| "Manifest registration 0 of 7 … STALE" | **STALE** — 31 entries registered, incl. all 7 3D tests | `STATUS_WAVE7_PHASE2.md:113,169`; `variant3d/tests/manifest.json` |
| "User windowed retest still pending" / "DONOR VISUAL PARITY STILL UNVERIFIED" | Second half **ACCURATE**; first half appears superseded by `PROGRESS.md:934-939` (user pasted clean windowed output, no script error). Keep as caveat, do not silently drop parity UNVERIFIED. | `STATUS_WAVE7_PHASE2.md:54-55`; `PROGRESS.md:934-939` |

---

## 5. Final 2D gate artifacts

| Artifact | Result | Evidence |
|---|---|---|
| `app/selftest.json` | `passed: true`, **29 steps, 29 passed / 0 failed** | direct JSON read; job 1342 `coord-variant-final-app-selftest-r2` `ok` |
| `app/uitest.json` | `passed: true`, **17 steps, 17 passed / 0 failed** | direct JSON read; job 1341 `coord-variant-final-app-uitest` `ok` |
| `variant3d/selftest.json` | `passed: true`, 29/29 | direct JSON read; job 254 |
| `variant3d/uitest.json` | `passed: true`, 17/17 | direct JSON read; job 255 |
| `variant3d/tests/results/t_render_mode.json` | `passed: true`, `seam_missing: false`, **10/10** | direct JSON read; job 256 |
| Clean verdict (2D) | `CLEAN` — stored summary: "clean CLEAN (0 processes, free lock, 9 acks)" | `docs/coord_swarm_2026-11-24/PROGRESS.md:912`; gate definition `variant3d/tools/CLEAN_GATE.md` / `docs/DECISION_LOG.md:49` (D-13: `failed` excluded, `timed-out`/`error`/`skipped` are failure statuses, D-14 acks honoured) |
| Last **verbatim** `assert_clean --json` output stored | **Older snapshot**, not the final gate: `verdict CLEAN`, `processes.clean=true count=0`, `lock free`, `history {total:500, acknowledged:30, failures:[]}` | `docs/QA_REPORT.md:338`. No verbatim final-gate JSON found in `docs/coord_swarm_2026-11-24/`; only the `PROGRESS.md:912` summary (and `FINAL_GATE.md:13-17` acceptance criteria) |
| Independent consistency check of current app spool | 9 failure-status jobs exist, **all 9 acknowledged**; `failed` jobs (75) excluded by D-13; `jobs/` empty, `now_serving == counter` → equivalent to CLEAN | `app/.godot_queue/status.json` direct read (§3) |

---

## Findings / risk register

| ID | Severity | Finding | Evidence | Disposition |
|---|---|---|---|---|
| F-01 | **HIGH** | 179,912,941 B atlas exceeds GitHub's ~100 MB per-file limit. Shipping depends on LFS being configured on the remote and fetched by clones; single-mode otherwise soft-fails. | §1 / §1a; `README.md:106`; `split_manifest.json:16,75-76` | Keep LFS or uncommitted; split parts (≤90 MB, hashes verified) are the safe fallback |
| F-02 | **HIGH** | Variant spool has **19 unacked `timed-out` jobs** (84 unacked non-ok in total). Any variant clean gate run today is DIRTY; the status doc undercounts as 60. | §3; `STATUS_WAVE7_PHASE2.md:40` | Ack resolved historical tickets or record explicit waiver; do not claim variant CLEAN |
| F-03 | MEDIUM | Docs drift: README says 28-step sim test twice; status badge/TL;DR still say final gate pending/not run; old gate ids 1289/1290 and "0 of 7 tests registered" remain in a "historical" section that a cold reader may still follow. | `README.md:45,64`; `STATUS_WAVE7_PHASE2.md:76,92,107,113,114,249-251` | Editorial fix by doc owner; final verdict itself is correct |
| F-04 | MEDIUM | Five atlas/mask PNGs have no `.import` sidecar while export uses `all_resources`; raw-byte loads work in-editor but export inclusion is UNVERIFIED. `res://assets/models/glb/` is referenced but absent (guarded, OBJ fallback). | §2a/§2b; `tile_atlas_loader.gd:306-318`; `world3d_entities.gd:62,449-451`; `export_presets.cfg` | Verify in an actual export before shipping; don't claim export-tested |
| F-05 | MEDIUM | Tracked probe/leftover files in the tests tree (`_v716_probe.gd`, 4 orphan `.uid`, 3 probe result JSONs) plus likely-unignored `.import~RF*.TMP` files. | §2c | Sweep by owner; `.gitignore:41-42,88,92-94` covers caches but not these names |
| F-06 | LOW | 295.6 MB of donor OGG audio in `variant3d/assets/sounds/`; private-use only, never redistribute (license caveat in README/CREDITS). | `README.md:32-34,220-224`; filesystem size | Keep donor assets out of public distribution; no change proposed |
| F-07 | LOW (honesty) | Status doc says "no variant `assert_clean.py`", but the tool exists; "no formal variant CLEAN" is still correct for a different reason (F-02). | `STATUS_WAVE7_PHASE2.md:41-42`; `variant3d/tools/assert_clean.py` | Correct the reason, not the caveat |
| F-08 | INFO | App job 1340 failed transiently and is unacked, but 1342 rerun is green and `failed` is excluded from the clean gate — not a release blocker. | app history; `PROGRESS.md:912-915`; D-13 | Keep the documented explanation |

**Scope limits / honesty notes:** no Godot process was started, no runner command was executed, no git command was issued, and no source/asset/config/test file was changed. LFS pointer content was not decompressed (git objects are packed); the LFS conclusion is based on `.gitattributes`, `.git/config`, the matching local LFS object, and the index path. Export behaviour was not executed. Visual parity remains UNVERIFIED by charter.
