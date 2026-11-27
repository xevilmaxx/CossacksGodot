---
id: PORT1TO1-ARTIFACT-LAYOUT-2026-11-26
title: "Definitive owner-facing artifact layout — full 1:1 Cossacks 3 donor port"
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER ARTIFACT-LAYOUT — READ-ONLY documentation report; exactly one repository file written
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_artifact_layout.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition parity chain 0/6 closed"
scope_guard: "Repo file/line reads plus read-only PowerShell directory listings and Get-FileHash of existing files only. No source, shader, config, asset, test, manifest, result JSON, backup, queue file, app/ byte, git state, Godot process, runner subcommand, gate, capture, ROI metric or donor binary was created, modified or executed. Exactly one repository file written: this report. No donor GPU A/B frame produced or compared."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§0, §2, §3, §4, §7, §8, §9)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (§1, §5, §6, §8)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (:319-323, §10 :326-341)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index.md (§Reading key, Domain sums)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_metrics.md (§0-§4)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_determinism_audit.md (§4, §5)
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md (§4)
  - docs/terrain_swarm_2026-11-26/reports/V112_gate_witness.md (§2)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_gate_audit.md (§0, §2)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_ack_evidence.md (§0, §2)
  - variant3d/tools/acceptance/README.md
  - inbox/qa/README.md
---

# PORT1TO1 — definitive artifact layout (owner-facing)

> **Mandatory reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **Verdict (verbatim governing form):** `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. The six-condition chain is **0/6 closed** (`PORT1TO1_parity_chain.md:39/58`); no donor GPU A/B frame exists; no worker may produce one under the read-only rule (`X39_ab_feasibility.md:32-37`, `PORT1TO1_acceptance_plan.md:188-190`). This report classifies artifacts. It **cannot make the owner parity decision**, and it makes **no parity claim** and supplies **no approximation**.

## 0. How to read this layout

- `[O]` = direct read-only filesystem/line observation at this pass. `[D]` = deterministic consequence of cited source/reports. `[U]` = unresolved; stays UNVERIFIED.
- Preservation classes used in every table:
  - **P (preserve-only, byte-frozen)** — owner mod or hashed witness. Never flip, revert, overwrite, "repair", re-apply, re-hash-into-agreement, delete or restore whole-file. Record SHA-256 before and after any capture (`PORT1TO1_owner_decisions.md:328`, `PORT1TO1_acceptance_plan.md:297/311`).
  - **E (evidence; preserve until owner decision/archive)** — generated captures, dumps, manifests, diffs, result JSONs. Regenerable **only** by owner/COORD/RUNTIME with fresh unique job ids; never fabricated, never re-run until green, never result-deleted.
  - **R (regenerable/disposable temp)** — outside the repo; may be discarded only after the evidence bundle in §6 is frozen and the owner has ruled. Absence before a run is expected, not a defect.
  - **D (design-only, absent)** — planned but not on disk; must not be represented as an artifact.
- A file being listed is evidence of **existence only** (`PORT1TO1_evidence_index.md:15`). Nothing in this layout upgrades a tier; no tier above 2 exists (`owner_decisions.md:40`, `acceptance_plan.md:368`).

---

## 1. Root map

| Path | Contains | Class | Regenerate / authority |
|---|---|---|---|
| `docs/terrain_swarm_2026-11-26/reports/` | Worker reports, one file per worker task. **315** `.md` files at this read `[O]`; the navigable `PORT1TO1_evidence_index.md` enumerated **300** at its 11:16 read `[O]` — the difference is later landed reports. | E | New report only by a worker with an explicit one-file ticket; never rewrite an existing report. Index: `PORT1TO1_evidence_index.md` §Reading key / Domain sums (A 116, B 27, C 30, D 14, E 113 at index read). |
| `docs/terrain_swarm_2026-11-26/spec/` | `README.md`, `00_EVIDENCE_INDEX.md` … `14_CURRENT_PIPELINE.md`, `terrain_qa_spec.json` (SCHEMA_ONLY, all bands `value:null`, `promotion.signed:false`). | E / P (no worker edits contradiction table) | `V34_doc_consistency.md`, `V56_final_doc_check.md` D-01/D-02; `inbox/qa/README.md:44`. Spec is not READY; no `--policy red` flip. |
| `inbox/qa/` | Fixture index `README.md`, `OWNER_CAPTURE_TEMPLATE.md`, fail-closed placeholders `PENDING_N7_validate_terrain_new.md`, `PENDING_N19_captures.md`, `terrain_qa_report.json.PENDING`. | P (placeholders) | `inbox/qa/README.md:13-29,65-98`. Do **not** rename a `.PENDING` to the real path; the real `inbox/qa/terrain_qa_report.json` is written only by `terrain_qa_harness.py --out` at COORD D-6 (`V21_gate_register.md:177`). |
| `inbox/qa/captures/` | Port snapshots, contact sheets, donor-direction MP4s, plan-view diagnostics, per-run sequence directories, ROI metric directories. | E / R | `PORT1TO1_acceptance_plan.md` §2-§4, §8; see §2-§4 below. |
| `inbox/backup/` | `<basename>.bak`, `.bak3`, `.bak-<LANE>` / `.g2bak` / `.broken-<LANE>` snapshots of every edited file. **P** for the two hashed I11 backups; the rest are write-evidence, not correctness evidence. | P / E | `V11_ownership_ledger.md`, `PORT1TO1_evidence_index.md:383` (129 untracked `.bak-<LANE>` at its read). Never restore a whole file from backup to "fix" a preserve-only mod. |
| `variant3d/scripts/*.bak-<LANE>` | Same lane-backup pattern in the variant script tree (e.g. `game.gd.bak-CAPSTATE2`, `water3d.gd.bak-WATERLIB`, `world3d_fog.gd.bak-ENDFOW`). | E | Proof of a landed write only. Rollback is file-scoped and reverse-order (`V11_ownership_ledger.md` §7), never `git reset --hard`. |
| `variant3d/tools/acceptance/` | `imgio.py`, `capture_sequence.py`, `contact_sheet.py`, `compare_frames.py`, `README.md`. | E (tooling; no edits by workers) | `variant3d/tools/acceptance/README.md` §Files / §1-§3; preflight `py_compile` in §4.1. |
| `variant3d/.godot_queue/` | `counter`, `now_serving`, `status.json`, `jobs/`, `results/<8-digit ticket>_<job-id>/{stdout.txt,stderr.txt}` and per-ticket result JSONs. | E (owner-managed spool) | `godot_runner.py run/status/ack`. **Never** `reset`/`doctor`/`cancel`/`unwedge`, never delete result JSONs or hand-edit status, never `--ignore-history` (`acceptance_plan.md:112/311`, `V42_gate_commands.md:45`). |
| `%TEMP%\opencode\v42\` | Outside-repo temp: `cap_*.png` + `cap_*.png.raw.png`, `map_{64,240,320}.json`, `map_donor_*.json`, `compare_smoke.json`, `mcp_qa_small.json`, `verify_mcp*.py`, and subdirs `diag/`, `dumps/`, `mcp_gamecraft/`, `video/`. `acceptance/` is **planned but absent** at this read `[O]`. | R | Regenerate with §4 commands. Never write capture artifacts into `variant3d/`. |
| `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\` | 12 read-only third-party H.264 stills `t_0.png`, `t_60`, `t_120`, `t_300`, `t_600`, `t_900`, `t_1200`, `t_1500`, `t_1800`, `t_2100`, `t_2260`, `t_2370` (all 1280×720). | P (read-only donor material) | **No regeneration by workers.** Video id `cZW0AEupCaI` (`Cossacks 3 - GAMEPLAY [PC/HD]`, 40:21.901). Direction-of-appearance only; `t_2260/t_2370` are water-candidate negatives (`acceptance_plan.md:44-45/68-69/97`). |

---

## 2. `inbox/qa/captures/` — exact names, contents, regeneration

| Artifact / pattern | Contents | Class | Regenerate / limits |
|---|---|---|---|
| `cap_*.png` (e.g. `cap_arrayatlas.png`, `cap_defaultcfg_donor.png`, `cap_donor_240*.png`, `cap_mapreuse.png`, `cap_millsow.png`, `cap_nationmove.png`, `cap_palmdesert.png`) | 1280×720 port snapshots from prior workers; point-in-time candidate-internal images. | E | Prior-worker outputs; not A/B. `cap_fullport6.png` and `cap_fullport7.png` are **absent** on disk at this read `[O]`, although named in `PORT1TO1_acceptance_plan.md:41` and corroborated absent by `PORT1TO1_parity_chain.md:52`. Do not synthesize them. |
| `contact_*.png` + `contact_*.json` (`contact_acceptance_smoke.json`, `contact_close-shorealpha.png`, `contact_shorealpha2.png`, `contact_wide-final.png`) | Pixel-preserving contact sheets (`exact_pixels_preserved=true`, `rescaled=false`) + per-tile source SHA-256 sidecars. `contact_acceptance_smoke.json:4` carries `parity=UNVERIFIED`. | E | `contact_sheet.py --manifest … --out … --cols 4 --hash-labels`; never `--fit` for fine-pattern judging (`acceptance_plan.md:198-207`). |
| `donor_240.mp4`, `donor_240_final.mp4`, `donor_240_wide2.mp4`, `donor_240_wide3.mp4`, `donor_64_final.mp4`, `donor_compare_contact.png` | Port-internal assembled videos / comparison contact, not donor captures. | E / R | `seq_to_mp4.py --dir … --fps … --out …`; must pass 7 mandatory guards (`acceptance_plan.md:222-230`). Missing ffmpeg returns 0 with contact only. |
| `map_overview_4k.png`, `map_overview_waterfix.png` | 4096×4096 (`waterfix` is 2048×2048 per `contact_acceptance_smoke.json:84`) deterministic whole-map **plan-view** compositor diagnostics. | E (diagnostic only) | `full_map_shot.py` §4.2; never feed to `compare_frames.py` against a 1280×720 donor frame; never claim water parity from pale blobs (`acceptance_plan.md:133-146`). |
| `fullport6_seq_20261113/` | `manifest.json` only (1405 B), `status="failed"`, view `donor` with `error=KeyError('seq_seconds')`; `01_donor/` exists but is **empty** `[O]`. | E (failed run; preserve as failure witness) | Do not delete or "repair"; superseded by `fullport6_seq2_20261113`. Read: `…/fullport6_seq_20261113/manifest.json:22,31-38`. |
| `fullport6_seq2_20261113/` | Landed admissible 3-frame port-internal sequence. See §2.1. | E (read-only witness) | `capture_sequence.py`; fresh subdirectory per run; harness refuses to overwrite `frame_*.png` (`README.md:40-41`). |
| `roi_metrics_20261113/` | 14 `diff_roi_R##_t<time>_<class>.png` + 14 matching `.json`, all `parity=UNVERIFIED`. See §2.2. | E | Exact 14 `compare_frames.py` commands at `PORT1TO1_roi_metrics.md:112-154`; all `--assert-ab-verified` omitted. |

### 2.1 `inbox/qa/captures/fullport6_seq2_20261113/` (exact layout) `[O]`

```
fullport6_seq2_20261113/
  manifest.json                    # schema 1, status=ok, deterministic=true, headless=false,
                                   # seed="20261113", parity="UNVERIFIED", runner_ticket=49,
                                   # capture_semantics="windowed seq = real viewport frames (frame_post_draw)"
  contact.png / contact.json       # 2572x1528 sheet; 3 tiles, exact_pixels_preserved=true
  01_donor/
    frame_0000.png                 # 1280x720; sha256_file 6fc7dfab26ea04429db165c4327604908b892cfa4707605d5eda32e8a6f4ba80
    frame_0001.png                 # 1280x720; sha256_file bbdec7c59c7ff4799480361810a27169c41e935a550b4b08a119756429ffe2e4
    frame_0002.png                 # 1280x720; sha256_file aa657352e5f659984a337fa211272daf926ad68784dc0c29708eacb61cd47676
    seq_index.json                 # frames=3, mode="window", seconds=2.0, sim_seconds=2.1875, step=1.0
    runner_stdout.txt              # 129 B
    runner_stderr.txt              # 0 B
```

Per-frame `sha256_pixels` and `resolution_observed/resolution_matches_request=true` are in `manifest.json:69-104`. Runner spool counterpart: `variant3d/.godot_queue/results/00000049_acapt-fullport6-donor/{stdout.txt,stderr.txt}` (`manifest.json:66-67`). Mechanical admissibility passes, but it is **port-internal evidence only** — still no donor A/B (`acceptance_plan.md:184`).

### 2.2 `inbox/qa/captures/roi_metrics_20261113/` (exact naming pattern) `[O]`

Files are `diff_roi_R<nn>_t<seconds>_<defect-class>.{png,json}` with `nn = 01..14`. Examples: `diff_roi_R01_t0_d1.*`, `diff_roi_R03_t300_d1.*`, `diff_roi_R11_t1800_d5a.*`, `diff_roi_R14_t2100_d4.*`. Every JSON has `tool="compare_frames.py"`, `schema=1`, `camera="NOT_SHARED_donor-oblique_vs_port-17p27"`, `config_donor=null`, `config_port=null`, `hist_bins=16`, `difference_image.mode="abs_diff_exact"`, `amplify=1.0`, `parity="UNVERIFIED"`, `claim=null`, `owner_assertion=null` (`PORT1TO1_roi_metrics.md:102`). Port side is F0 = `fullport6_seq2_20261113/01_donor/frame_0000.png` in every row. All 14 runs exited 0 with zero refusals; the numbers are support cues only, never thresholds, never a similarity %, never parity (`PORT1TO1_roi_metrics.md:25-27/160-162/172-185`).

---

## 3. `%TEMP%\opencode\v42\`, donor frames, MCP tools, deterministic harness

| Path | Exact contents at this read `[O]` | Class | Regeneration / authority |
|---|---|---|---|
| `%TEMP%\opencode\v42\` root | `cap_1to1_render*.png`, `cap_arrayatlas.png`, `cap_defaultcfg_donor.png`, `cap_donor_240[b..n].png`, `cap_donor_240_colorfield.png`, `cap_donor_240_hires.png`, `cap_donor_240_lightmatch.png`, `cap_fullport*.png`, `cap_mapreuse.png`, `cap_millsow.png`, `cap_nationmove.png`, `cap_otherclass.png`, `cap_palmdesert.png`, `cap_* .png.raw.png`, `probe_main.png`, `map_64.json`, `map_240.json`, `map_320.json`, `map_donor_*.json`, `compare_smoke.json`, `compare_smoke_diff.png`, `mcp_qa_small.json`, `verify_mcp.py`, `verify_mcp_tools.py`. | R | Prior point-in-time temp captures; §4 commands regenerate the relevant subsets. `.raw.png` is the unprocessed engine write; never overwrite a landed capture. |
| `v42\diag\` | `height.raw`, `terrain.raw`, `tileblock.raw`, `collision.raw` (16384/4096/4096/16384 B), `heightmap.png`, `heightmap.txt`, `tile_id_map.png`, `stats.json` (1,579,042 B). | R | Diagnostic raw dumps; no parity claim. |
| `v42\dumps\` | `v42_64_a.json`, `v42_64_b.json` (54,810 B each); `v42_240_a/b.json` (593,037 B each); `v42_320_a/b.json` (1,062,792 B each). | E until D1/D3 ruled; then R | Exact 6 `godot_runner.py run --dump-map` commands at `V42_gate_commands.md:216-226`; `scan_map.py --dir …/dumps` (`:228`); `terrain_qa_harness.py --dump-a/--dump-b/… --policy advisory` (`:237`). Whole-file SHA equality is port-internal `[D]` only; D1 five-stream zero-difference requires N16 (`V42:240`). |
| `v42\video\` | `donor_240/`, `donor_240_final/`, `donor_240_wide2/`, `donor_240_wide3/`, `donor_64_facegate/`, `donor_64_final/`, `donor_64_nosub/`, `donor_64_shorealpha/`, `donor_64_shorealpha2/`, `ground-grid-ab/`; MP4s `donor_240.mp4`, `donor_240_final.mp4`, `donor_240_wide2.mp4`, `donor_240_wide3.mp4`, `donor_64_final.mp4`. | R | `seq_to_mp4.py` + `ffmpeg` diagnostic extraction at exact indices (`acceptance_plan.md:214-230`); `VIDEO_SHA256SUMS.json` enumerated **before** writing itself. These are assembled port videos, not donor frames. |
| `v42\mcp_gamecraft\` | `shot_0001.png`, `vid_0002.png` … `vid_0005.png` (933,438 B each). | R | MCP host tool `game.screenshot` / `video.record_frames` output; see below. |
| `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\t_*.png` | 12 donor stills, 1280×720. Recorded SHA-256 in `PORT1TO1_roi_metrics.md:104`: `t_0=b037afde…c45`, `t_120=59039e2d…e6677`, `t_300=cc3baa4b…9523f`, `t_600=326a33d3…3dbed`, `t_1200=a98ef75b…5ae187`, `t_1800=7def3a3d…0a96b937`, `t_2100=5e14ed4f…d69aeb`. | P (read-only) | Owner-provided; workers never extract, copy, execute or commit donor material (`X39:32`). Not an admissible A/B; camera/projection unmatched. |
| MCP host tools | Live host `http://127.0.0.1:8931/mcp` (JSON-RPC `initialize`, `tools/list`, `tools/call`): `game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`. Probe scripts `%TEMP%\opencode\v42\verify_mcp.py` and `verify_mcp_tools.py`; output `%TEMP%\opencode\v42\mcp_qa_small.json`. In-repo protocol constants: `variant3d/tests/t_mcp_host.gd:23-31`; backup `inbox/backup/t_mcp_host.gd.bak-MCPPROTO` (`DEC_U_port_guard_audit.md:47/131`). | E (tooling/telemetry) | Regenerate only through a live host probe; `verify_mcp.py:76` states "protocol level only; no parity claim". MCP `game.tick` is cited as an optional fixed-tick driver in `PORT1TO1_determinism_audit.md:81`; it is not a donor A/B and does not implement the fixed-step design. |
| Deterministic capture harness | `variant3d/tools/acceptance/capture_sequence.py` is the **only legal serial viewport harness** (windowed `--seq` + `frame_post_draw`; `--headless` is a CPU map timelapse and is never donor-legal). `--deterministic-capture` / `--capture-ticks <N>` exist **only as an unapplied design** in `PORT1TO1_fixed_step_plan.md:60-66/149/179/510-534/629/696-699`; a full-tree read found no such symbols in `variant3d/` (`PORT1TO1_parity_chain.md:86`). | D (flags) / E (harness) | Do not claim the design is implemented. Closing condition 4/6 requires the `fixed_step_plan §8` two-run test (seed 20261113, pinned config SHA, `--capture-ticks 768`, 24 frames, byte-identical `sha256_pixels`, clean stderr, 1280×720) — still port-internal only. |

---

## 4. Exact regeneration commands (owner/COORD only; PowerShell from repo root)

Repo root: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`. PowerShell `;`, never `&&`; `<T> = C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42`. Every Godot launch goes through `python variant3d/tools/godot_runner.py run` with a **fresh unique `--id`**; call `status` after every `run` and require `pending=0`, lock free, counters aligned (`V42_gate_commands.md:45`, `V112_gate_witness.md:41`). Never accept exit 0 alone: require result envelope `status=ok`, `exit=0`, `SCRIPT ERROR=0`, result mtime **after job START**, and `scan-stderr script_error_lines=0`.

### 4.1 Static preflight (no Godot) — `PORT1TO1_acceptance_plan.md:117-127`

```powershell
python -m py_compile variant3d/tools/acceptance/imgio.py `
  variant3d/tools/acceptance/capture_sequence.py `
  variant3d/tools/acceptance/contact_sheet.py `
  variant3d/tools/acceptance/compare_frames.py
python variant3d/tools/godot_runner.py status
python variant3d/tools/assert_clean.py --json
Get-Command ffmpeg,ffprobe -ErrorAction SilentlyContinue
python -c "import PIL; print(PIL.__version__)"
Test-Path "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png"
```

Accept only `py_compile` exit 0, quiet/clean runner, ffmpeg + ffprobe + Pillow present, donor frames present. Missing ffmpeg is a hard block for MP4 (`seq_to_mp4.py` returns 0 with contact only).

### 4.2 4K plan-view compositor (diagnostic, never donor-legal) — `acceptance_plan.md:135-140`

```powershell
python variant3d/tools/full_map_shot.py --gen-dump --seed 20261113 `
  --config variant3d/config_donor_capture.json `
  --dump "$env:TEMP\opencode\v42\acceptance\map_overview_dump.json" `
  --out "$env:TEMP\opencode\v42\acceptance\map_overview_4k.png" --tile-px 64
```

### 4.3 Wide/close sequences — `acceptance_plan.md:154-173`

```powershell
$Acc = Join-Path $env:TEMP 'opencode\v42\acceptance'
New-Item -ItemType Directory -Force -Path $Acc | Out-Null
Copy-Item variant3d\config_donor_capture.json (Join-Path $Acc 'wide_config.json') -Force
Copy-Item variant3d\config_donor_capture.json (Join-Path $Acc 'close_config.json') -Force
# In close_config.json set ONLY camera.start_zoom = 2.9; keep pitch -32, fov 17.27,
# 1280x720, random_seed 20261113, backend donor. Record both SHA-256 values.
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label accept1 `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --view close=(Join-Path $Acc 'close_config.json') `
  --mode seq --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/accept1_20261126
```

Admissibility (`acceptance_plan.md:177-184`): `status=ok`, every view `complete=true`, `runner_status=ok`, `runner_exit=0`, `headless=false`, exact `capture_semantics`, `resolution_observed=1280×720` and `resolution_matches_request=true` (the discriminator against silent 800×600 CPU fallback), config SHA-256 equal to the temp copy, per-frame `sha256_file` + `sha256_pixels`, `parity=UNVERIFIED`. A winner early stop records `complete=false` and exits non-zero.

### 4.4 Contact sheet / MP4 — `acceptance_plan.md:199-220`

```powershell
python variant3d/tools/acceptance/contact_sheet.py `
  --manifest inbox/qa/captures/accept1_20261126/manifest.json `
  --out inbox/qa/captures/accept1_20261126/contact.png --cols 4 --hash-labels

python variant3d/tools/seq_to_mp4.py `
  --dir "$env:TEMP\opencode\v42\acceptance\wide240" --fps 6 `
  --out "$env:TEMP\opencode\v42\acceptance\wide240.mp4"
python variant3d/tools/seq_to_mp4.py `
  --dir "$env:TEMP\opencode\v42\acceptance\close64" --fps 8 `
  --out "$env:TEMP\opencode\v42\acceptance\close64.mp4"
```

`seq_to_mp4.py` reads four-digit `frame_%04d.png` only (three-digit names fail) and never reads fps from a manifest. Then apply the 7 guards at `acceptance_plan.md:222-230`.

### 4.5 ROI metrics — `PORT1TO1_roi_metrics.md:112-154` (14 commands; pattern shown)

```powershell
python variant3d/tools/acceptance/compare_frames.py `
  --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" `
  --port inbox/qa/captures/accept1_20261126\01_wide\frame_0000.png `
  --roi 400,350,500,250 `
  --roi-source "manual ROI: donor video cZW0AEupCaI t=600, inter-rock/mill-class ground; port side re-located on fresh wide frame (locator only)" `
  --camera wide `
  --out-diff inbox/qa/captures/accept1_20261126\diff_t600_wide.png `
  --report inbox/qa/captures/accept1_20261126\diff_t600_wide.json
```

Mandatory: `--donor`, `--port`, `--roi x,y,w,h`, `--roi-source` (≥10 chars), `--camera`. Refusals (exit 2): missing args, ROI outside frame, different resolutions, differing config SHA-256. Always prints `parity=UNVERIFIED`; `--assert-ab-verified` writes `claim=owner-supplied` but never promotes parity (`acceptance_plan.md:247-252`).

### 4.6 Determinism dumps / structural gates — `V42_gate_commands.md:216-237`, `V112_gate_witness.md:58-60`

```powershell
python variant3d\tools\godot_runner.py run --id v42-dump-64-a --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_64.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_64_a.json" --timeout 600
# repeat with v42-dump-64-b / v42_64_b.json, then 240-a/b and 320-a/b (V42:218-226)
python variant3d\tools\scan_map.py --dir "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps"
python variant3d\tools\terrain_qa_harness.py --dump-a "…/v42_240_a.json" --dump-b "…/v42_240_b.json" --seed-manifest "…/map_240.json" --policy advisory --out "…/qa_harness_report.json" --check
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v42-dump-320-b\stderr.txt
Get-FileHash "…\v42_64_a.json","…\v42_64_b.json","…\v42_240_a.json","…\v42_240_b.json","…\v42_320_a.json","…\v42_320_b.json" -Algorithm SHA256
python variant3d\tools\assert_clean.py --json
```

Keep `--policy advisory` everywhere; never relax `scan_map.py:478-493`; never label a 240² config frame "320²" (`V42:38/102/365`). D1 five-stream zero-difference must come from N16, not whole-file SHA (`V42:240`).

### 4.7 Preserve-only hash re-verification — `V42_gate_commands.md:345`, `parity_chain.md:113`

```powershell
Get-FileHash variant3d\scripts\main.gd,variant3d\scripts\world3d.gd,inbox\backup\main.gd.bak-COORD-I11,inbox\backup\world3d.gd.bak-COORD-I11 -Algorithm SHA256
Get-FileHash variant3d\config_donor_capture.json,variant3d\config.json,variant3d\assets\models\manifest.json -Algorithm SHA256
```

Run **before and after** every capture; a changed preserve-only hash invalidates the run (`owner_decisions.md:328`, `acceptance_plan.md:297/311`).

---

## 5. Preserve-only versus disposable — decision table

| Artifact | Class | Exact must-not-change / disposal statement |
|---|---|---|
| `variant3d/config.json` | **P** | `features.terrain.backend="donor"` (`:29`), `relief_stamps=true` (`:30`), `color_unify=true` (`:31`); water `alpha_confine=true`, `shore_prox=false`; camera `-32°`, `min_height=20`, `max_height=58`, `start_zoom=0.3448276`, `fov_deg=17.27`, 1280×720, `pixels_per_meter=16`; seed 20261113, 240×240, `render_mode="3d"`. Never flip backend to legacy to hide a defect (`owner_decisions.md:332`, `acceptance_plan.md:301-305`). |
| `variant3d/config_donor_capture.json` | **P** | `backend="donor"` (`:31`), `demo_mill=true` (`:32`), water keys `:34-37`. `demo_mill` is an owner mod — never remove. Hash witness §5.1. |
| `variant3d/assets/models/manifest.json` | **P** | `ukr/buildings` (`:1880-2033`), `commoneur/eur*.osm` aliases (`:2040,2065,2090,2115,2164,2188`), sid `field` → `field1.osm`/`shared/terrain/field` (`:2581-2602`). Rollback is id-level only, never whole-file restore (`owner_decisions.md:334`). |
| I11 seam `main.gd:125/189-191/593-594/1112-1113`, `world3d.gd:118/144/147/148/223-227/624/645/707-710` | **P** | Single-applied; **never re-apply the seam or flip the default** (`owner_decisions.md:335`, `acceptance_plan.md:306`). |
| Shader/mesh/v5-save owner mods, demo-mill/fields/builder-stands | **P** | `scene_color=vec3(0.2)`, `sampler2DArray tile_array`, `tile_map` binding, `color_unify_gain=vec3(1.0)`, specular zero, CPU-baked `uv0/uv1`; `save_v5` additive-only `"version":5`, restore `>=5` (`owner_decisions.md:336-337`). |
| Preserved donor contradictions | **P** | `TileSmoothPasses=6` vs `SmoothTileMap(...,3)` (use **3**; carry 6; runtime `[U]`); `tilesmooth.cfg` editor-only vs weighted `tilesmooth_scripts.cfg`; `m_swamp_12_old` 17×20/18×23 (binary authority, quarantine, never abort 680-record parse); port 8 id-mod-64 zeros vs donor `alphanull` 86/110/123; `specular_rgb` effective `vec3(0)`; `lake_big := plain*2*0`. Never "fix" (`owner_decisions.md:339`, `V47_final_contradictions.md:62-65`). |
| `inbox/backup/*.bak-<LANE>`, `variant3d/scripts/*.bak-<LANE>` | **P** (two I11 hashes) / **E** (rest) | Write-evidence only. Do not restore whole files; do not delete the two I11 witnesses. |
| `inbox/qa/*.PENDING`, `PENDING_N*.md` | **P (fail-closed)** | Not consumable; real expected paths stay absent; delete only by owning worker **after** the real artifact lands and its hash is entered in `inbox/qa/README.md` §3 (`inbox/qa/README.md:16-24/107`). |
| Reports / spec / harness scripts | **E / P** | One file per worker ticket; no worker edits another worker's report, a gate, an assertion, a threshold, a manifest or the spec contradiction table. |
| Root temp captures, `v42\diag\`, `v42\video\`, `v42\mcp_gamecraft\`, planned `v42\acceptance\` copies, `contact*.png`, `diff_*.{png,json}`, assembled MP4s, `VIDEO_SHA256SUMS.json` | **R** | Regenerable/disposable **only after** the §6 bundle is frozen and COORD rules. Never write into `variant3d/`. Never fabricate a frame, ROI, provenance string or diff to force a pass. |
| `inbox/qa/captures/fullport6_seq2_20261113/`, `roi_metrics_20261113/`, `v42\dumps\`, runner `results/` | **E until owner decision** | Preserve as point-in-time witnesses; never delete or overwrite to force a rerun; absence of expected runtime outputs before a run is normal (`owner_decisions.md:338`, `V13_stale_qa_refs.md §2`). |
| `--deterministic-capture` / `--capture-ticks` | **D (absent)** | Design-only; do not claim implementation. `main.gd:1635-1642` is still frame-paced with watchdog truncation (`parity_chain.md:86`). |

### 5.1 The three preserve-only items with recorded hashes

All three were re-read with read-only `Get-FileHash -Algorithm SHA256` at this pass and **match** the recorded baselines `[O]`. A match is point-in-time byte preservation evidence, **not** donor parity and **not** a gate pass.

| # | Artifact | Recorded SHA-256 | Where recorded | Re-verify rule |
|---|---|---|---|---|
| P-2 | `variant3d/config_donor_capture.json` | `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` | `owner_decisions.md:333`, `acceptance_plan.md:310`, `fullport6_seq2_20261113/manifest.json:65`, `parity_chain.md:113` | Before and after every capture; a new run's config hash must equal this to be treated as the same capture contract. |
| P-4a | `inbox/backup/main.gd.bak-COORD-I11` | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` | `owner_decisions.md:335`, `acceptance_plan.md:306`, `parity_chain.md:113`, V102 §Seam / V65 §8 / V95 item 5 | Exact V11 E1 / V76 baseline; never re-apply the seam. |
| P-4b | `inbox/backup/world3d.gd.bak-COORD-I11` | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` | `owner_decisions.md:335`, `acceptance_plan.md:306`, `parity_chain.md:113`, V102 §Seam / V65 §8 / V95 item 5 | Exact V11 E2 / V76 baseline; late-switch refusal at `world3d.gd:223-227` stays. |

**No baseline hash exists in the cited reports** for these two preserve-only files (`owner_decisions.md:332/334`, `parity_chain.md:114/145`):

- `variant3d/config.json` — current point-in-time read `223767E57B506577EAD54633708380A425A0B8AA439C8E3C28478C15C8ED44E2` (report prefix `223767e57b506577…`). **Not evidence of preservation against a baseline.**
- `variant3d/assets/models/manifest.json` — current point-in-time read `36F6A378548F3116DC1585D7CDD34526A17B5C46D1DED02E3A93C7C736F22731` (report prefix `36f6a378548f3116…`). **Not evidence of preservation against a baseline.**

Also recorded but **not re-verified by the parity-chain audit**: six P-9 tool hash prefixes `ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77` (`owner_decisions.md:340`, V55 E10 / V90 §7) and donor pin `cossacks.exe` SHA-256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` (`t_87f0f3c130b0`; read-only, never executed). COORD must re-run `py_compile` at A′-1 on the frozen tree.

---

## 6. Minimal evidence bundle required for an owner parity decision

The owner decision **cannot be made under the read-only rule**. It requires **all six** conditions below; status at this pass is **0/6 closed** (`PORT1TO1_parity_chain.md:39/58`, chain defined at `owner_decisions.md:319` and `V109_owner_answer_final.md:91`). No subset, no ROI metric, no contact sheet, no MP4 and no unit-test PASS substitutes for any condition.

| # | Condition | Minimal artifact(s) that would close it | State now |
|---|---|---|---|
| 1 | Genuine same-size/seed/type/season/camera/ROI **donor GPU frame** | Owner-run donor PNG **outside the repo** + written key/camera/size/season/ROI manifest per `X39 §3` (`randkey0/1`, size enum, map type, season, camera constants, fractional ROI). Donor binary never executed or copied by a worker. | **BLOCKED** — no such frame exists; 12 H.264 stills are third-party, unknown build/camera/zoom/compression; `t_2260/t_2370` are negatives. |
| 2 | Admissible non-blank **1280×720** candidate capture | Fresh capture directory with `manifest.json` (`status=ok`, `complete=true`, `headless=false`, `resolution_matches_request=true`, pinned seed/camera/size, config SHA, per-frame `sha256_file`/`sha256_pixels`), `frame_%04d.png`, `seq_index.json`, `runner_stdout.txt`, `runner_stderr.txt`, `script_error_lines=0`, identical ROI. | **PARTIAL, port-internal only** — `fullport6_seq2_20261113` is mechanically admissible but not A/B; `cap_fullport6/7.png` absent. |
| 3 | Inputs **matched and labelled** | A/B-L1 same-keys manifest (both sides' keys/size/type/season/camera/ROI) **or** A/B-L2 importer-rendered same geometry (D04 §7 importer upgrade). Unmatched seed or unverified ROI degrades to direction-only. | **BLOCKED** — `--camera NOT_SHARED_donor-oblique_vs_port-17p27`; donor has no numeric seed UI; `randkey0/1` derivation `[U]`. |
| 4 | Fresh gates green, not stale | Runner result JSONs with mtime after job START; D1 dumps (5 streams × 3 sizes 64²/240²/320², zero byte difference via N16); D3 run integrity `status∉{timed-out,error,skipped}`, `script_error_lines=0`, CLEAN; selftest 29/29, uitest 17/17, `t_render_mode` PASS, `t_map_variety` 5/5, `scan_map ALL GREEN`, `assert_clean` CLEAN with **575/582/585 acknowledged with evidence-backed reasons** (never deleted, never `--ignore-history`); `app/**` byte-identical; preserve-only SHA table before/after. | **BLOCKED** — 575/582/585 unacked; their result JSONs do not resolve on disk; `inbox/qa/**` PENDING; `terrain_qa_spec.json` SCHEMA_ONLY; no D1/D3 ruling; advisory posture only. |
| 5 | Spec/toolchain evidence completed | §§01–14 READY; X15 root `manifest.json`; I05 atlas built and bound; I03 feed consumed with `props_total>0 && fallback_used=false`; N17 populated and signed; **`blocking_unverified=[]`** ruled by COORD. | **BLOCKED** — ~45 labelled approximations, atlas tier ABSENT, Objects feed unwired, root manifest absent, `blocking_unverified` non-empty. |
| 6 | **Demonstrated byte-identical geometry + pixel-identical frame**, COORD ruling | COORD-signed owner report explicitly ruling condition 6 under the proven-matched manifest, zero mismatch. | **BLOCKED** — no such report; `--assert-ab-verified` never promotes parity; a passing replay pair stays port-internal only. |

**Bundle contents, minimally:** (1) the owner donor frame + matched-input manifest; (2) the admissible candidate capture directory; (3) the A/B-L1 or A/B-L2 matching proof; (4) the fresh gate envelope, six dumps + `scan_map` + N16 D1 report + D3 CLEAN + acked 575/582/585 + `app/**` and preserve-only hash tables; (5) the completed spec/toolchain set with signed N17 and `blocking_unverified=[]`; (6) the COORD-signed zero-mismatch ruling. Until all six exist, the honest verdict template is:

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — <one blocking item; rollback/hold>.
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = <non-empty list; e.g. PT-V1…PT-V8, P0-1…P0-8, W-R1, T-SEED,
                       T-CALLBACK, atlas-layout, plus domain residuals>
```
(`acceptance_plan.md:357-366`, `roi_metrics.md:168-183`). Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor-threshold PASS", or "gate PASS" derived from a capture (`acceptance_plan.md:370`).

---

## 7. Explicit statements and claim register

1. **No approximation was supplied, no gate was run, no donor binary executed, no GPU frame captured or compared, no Godot process, runner subcommand, git operation, capture, contact sheet, MP4 or ROI metric was produced by this worker.** Exactly one repository file was written: this report.
2. **The three recorded preserve-only hashes match current bytes at this pass** `[O]`; the two unhashed preserve-only files carry point-in-time readings only and no baseline claim.
3. **No parity claim.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim=false`; no tier above 2 exists.
4. **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — P0-1…P0-8 remain open, no donor GPU A/B frame, no admissible matched capture, no D1/D3 ruling and no COORD sign-off (`parity_chain.md:40/132`, `owner_decisions.md:14/39/353`, `acceptance_plan.md:33/269`).
5. This layout is a navigation and preservation document. It does **not** close any `[U]`, promote any metric, acknowledge any ticket, or make the owner parity decision.

*End of PORT1TO1_artifact_layout. Read-only documentation; exactly one repository file written. Parity UNVERIFIED; no approximation, no parity claim.*
