# PORT 1:1 — Video-Internal Review (port-internal defect detection only)

- Scope: READ-ONLY port-internal review of deterministic viewport frames on disk. No donor execution, no donor copying, no code/config/asset/Godot/git edits, no new capture.
- Parity: **UNVERIFIED**. Parity chain: **0/6**. **RESULT IS NOT GOOD** while `blocking_unverified` is non-empty.
- `byte_identical=TRUE` anywhere in this report means **port-internal repeatability only** (chain condition 6 PARTIAL, not CLOSED). It is never donor parity and never parity evidence.
- No visual observation in this report promotes parity. No approximations are used to claim parity.
- Explicit negative statements (verified by inspection of this review's inputs):
  - No donor A/B frame was compared here.
  - No matched-camera donor-vs-port pair exists in this review.
  - No COORD ruling is made or implied here.
  - No donor video/frame was executed, copied, or measured here.

## Method

- Tools: `read` (PNG visual), read-only file/glob/grep, shell with Python 3.14 + `cv2`/`PIL`/`numpy` for measurement only.
- Sets inspected: `lastcheck_20261127`, `lastcheck_20261127_repeat` (primary), plus `finalcheck_20261127`, `finalcheck_20261127_repeat`, `finalcheck2_20261127`, `detcheck_20261113`, `detcheck2_20261113`, `repcheck_20261113`, `repcheck_20261113_repeat`, `fullport6_seq2_20261113`, `fullport6_seq_20261113` (manifest only — 0 PNGs on disk), top-level `cap_fullport6/7/8.png` (ad-hoc single captures, not deterministic sets).
- Per frame computed: size, file bytes, SHA-256 (file), mean/std per BGR channel, unique-colour count, pure-black fraction, pure-white fraction, frame-to-frame changed-pixel percentage, blue-dominant (water-like) fraction, dominant terrain-green-band fraction.
- Manifest claims cross-checked against recomputed values (hashes, resolution, frame counts).

## Artifact table (exact paths + computed numbers)

All PNGs below are 1280x720 unless noted. Mean/std are BGR order (OpenCV). `changed%` = share of pixels with any channel different vs previous frame in the same set.

### A. Primary set: lastcheck_20261127 (and repeat)

| Path | Bytes | SHA-256 (file, recomputed) | Mean BGR | Std BGR | Unique colours | Black % | White % | Changed % vs prev |
|---|---|---|---|---|---|---|---|---|
| `inbox/qa/captures/lastcheck_20261127/01_donor/frame_0000.png` | 1024153 | `a776159f6233de53ea51eeb1e8fa9fe91655091f60ed2821aa941e5996b7c876` | (36.98, 69.24, 67.19) | (9.27, 10.37, 12.33) | 30964 | 0.0298 | 0.0000 | — |
| `inbox/qa/captures/lastcheck_20261127/01_donor/frame_0001.png` | 1027048 | `167764bffe19ec7a8421e3b4d36528e08a20aaf85245d28477b2a2ef4c64ea3b` | (36.98, 69.20, 67.15) | (9.35, 10.57, 12.49) | 31153 | 0.0487 | 0.0000 | 99.0503 |
| `inbox/qa/captures/lastcheck_20261127_repeat/01_donor/frame_0000.png` | 1024153 | `a776159f6233de53ea51eeb1e8fa9fe91655091f60ed2821aa941e5996b7c876` | identical to primary f0 | identical | 30964 | 0.0298 | 0.0000 | — |
| `inbox/qa/captures/lastcheck_20261127_repeat/01_donor/frame_0001.png` | 1027048 | `167764bffe19ec7a8421e3b4d36528e08a20aaf85245d28477b2a2ef4c64ea3b` | identical to primary f1 | identical | 31153 | 0.0487 | 0.0000 | 99.0503 |

- Byte identity primary↔repeat: frame_0000 match TRUE, frame_0001 match TRUE (full SHA-256 compared, not prefix). Manifest `repeat_verification.json` claim `byte_identical:true, mismatch_count:0` CONFIRMED by recomputation. This is port-internal repeatability only (condition 6 PARTIAL).
- Manifest cross-check (`lastcheck_20261127/manifest.json`): `parity:"UNVERIFIED"` present; `status:"ok"`; `deterministic:true`, `deterministic_capture:true`, `capture_ticks:64`, `seed:"20261113"`, `expected_resolution:[1280,720]`; view `donor` frame_count 2, resolution_observed 1280x720, `resolution_matches_request:true`; per-frame `sha256_file`/`sha256_pixels`/width/height all match recomputed file hashes and measured dimensions. `seq_index.json` on disk confirms `{capture_ticks:64, deterministic:true, frames:2, mode:"window", seconds:2.0, sim_seconds:2.0, step:1.0, ticks_done:64, ticks_per_frame:32, winner:-1}`. No discrepancy found between manifest claims and disk.
- Inter-frame structure: mean abs diff f0→f1 is small — (B 3.61, G 4.97, R 5.18) per channel, max 231; only 0.95% pixels exactly equal, 11.36% within max-channel-diff ≤1, 28.32% within ≤2. Integer-shift test (±2 px, 25 offsets) does NOT explain it (best shift still 98.89% changed vs 99.05% unshifted) — i.e. this is not a camera pan; it is a near-global low-amplitude per-pixel change (dither/grain/shader-time animation) plus local motion (windmill blades, unit sprites; see visual notes).
- Uniform-region check: no large flat field — top-5 colours each ≤1.44% of pixels (f0 top: BGR (36,66,64) 1.439%; (36,68,64) 1.376%; (36,67,64) 1.269%). Terrain-green band (B 25–50, G 55–85, R 50–85) covers 92.56% of f0. No letterbox: first-5-row mean ≈ last-5-row mean (≈BGR 37.5,68.9,65.8 vs 37.3,68.8,65.8). Pure-black pixels (n=275, 0.03%) are scattered inside building/unit sprite bounds (bbox x 740–1211, y 50–288), not frame borders — sprite/text dark pixels, not a defect.
- Water check: blue-dominant fraction (B > G+20 and B > R+20) = **0.000%** on both frames. Recorded as EXPECTED under the hard-fail gate (missing water is policy-expected, not a defect found by this pass).

### B. Other deterministic 2-frame sets (all byte-identical to lastcheck frames)

| Set / path | Bytes f0 / f1 | SHA-16 f0 / f1 | Stats vs lastcheck |
|---|---|---|---|
| `inbox/qa/captures/finalcheck_20261127/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | `a776159f…` / `167764bf…` | numerically identical (mean/std/uniq/changed% equal) |
| `inbox/qa/captures/finalcheck_20261127_repeat/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | same pair | identical |
| `inbox/qa/captures/finalcheck2_20261127/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | same pair | identical |
| `inbox/qa/captures/detcheck_20261113/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | same pair | identical |
| `inbox/qa/captures/detcheck2_20261113/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | same pair | identical |
| `inbox/qa/captures/repcheck_20261113/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | same pair | identical |
| `inbox/qa/captures/repcheck_20261113_repeat/01_donor/frame_0000.png`, `frame_0001.png` | 1024153 / 1027048 | same pair | identical |

- Cross-set finding: all 9 `frame_0000.png` files share one SHA-256; all 9 `frame_0001.png` files share one SHA-256 (verified full-hash). Every 2-frame deterministic set on disk is the same capture repeated, not an independent scene. Manifests for `finalcheck_20261127` and `repcheck_20261113` also carry `repeat_verification:{byte_identical:true,…,"note":"port-internal repeatability only; never donor parity"}` with `parity:"UNVERIFIED"` — consistent, no promotion to parity.
- Consequence for defect detection: these sets contribute zero additional visual coverage; any frame defect present in lastcheck is present in all of them (and vice versa).

### C. fullport6_seq2_20261113 (distinct scene, 3 frames + contact sheet)

| Path | Bytes | SHA-16 | Mean BGR | Std BGR | Unique | Black % | White % | Changed % |
|---|---|---|---|---|---|---|---|---|
| `inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png` | 1059468 | `6fc7dfab26ea0442` | (36.16, 65.80, 63.82) | (17.96, 26.00, 25.80) | 40629 | 0.1718 | 0.0026 | — |
| `inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0001.png` | 1060266 | `bbdec7c59c7ff479` | (36.12, 65.74, 63.75) | (18.00, 26.08, 25.85) | 40820 | 0.1905 | 0.0026 | 0.4878 vs f0 |
| `inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0002.png` | 1060853 | `aa657352e5f65998` | (36.14, 65.76, 63.77) | (18.03, 26.10, 25.87) | 40888 | 0.1891 | 0.0026 | 0.4642 vs f1 |
| `inbox/qa/captures/fullport6_seq2_20261113/contact.png` (sheet 2572x1528, Pillow; tiles exact-pixels-preserved per `contact.json`) | 2046218 | — (presentation assembly, not a viewport frame) | — | — | — | — | — | — |

- Unlike the 2-frame sets, inter-frame change here is tiny (0.49%, 0.46%) — near-static scene with HUD. Higher std/unique counts than lastcheck come from HUD chrome (resource bar, minimap, selection panel), not terrain. Terrain-green band 68.27% (lower because HUD panels cover frame edges). Blue-dominant fraction 0.000% (no water visible; expected under hard-fail gate).
- `contact.json` explicitly notes: "Presentation only. A contact sheet and metrics alone never constitute donor parity; parity=UNVERIFIED." Concur — cited as evidence of non-promotion, not as defect.

### D. fullport6_seq_20261113 (manifest only)

- `inbox/qa/captures/fullport6_seq_20261113/manifest.json`: `status:"failed"`, view `donor` error `KeyError('seq_seconds')`, 0 PNGs on disk. No frames to inspect; recorded honestly as absent, not as zero-defect. Not counted toward any repeatability claim.

### E. Ad-hoc single captures (NOT deterministic sets — reference only)

| Path | Bytes | Mean BGR | Std BGR | Unique | Black % | Blue-dominant % |
|---|---|---|---|---|---|---|
| `inbox/qa/captures/cap_fullport6.png` (1280x720) | 980749 | (37.71, 68.91, 66.83) | (6.20, 9.94, 11.57) | 27208 | 0.0675 | 0.000 |
| `inbox/qa/captures/cap_fullport7.png` (1280x720) | 928080 | (37.72, 68.94, 66.84) | (6.14, 9.82, 11.44) | 26644 | 0.0519 | 0.000 |
| `inbox/qa/captures/cap_fullport8.png` (1280x720) | 929090 | (37.72, 68.93, 66.83) | (6.15, 9.82, 11.42) | 26503 | 0.0528 | 0.000 |

- No manifests; excluded from determinism conclusions. Included so the report does not silently omit present `cap_fullport*.png` files. (`cap_fullport6.png` pixels differ from every deterministic frame above; 7/8 are near-duplicates of each other by stats — no hash-identity claim made without need.)

## Visual description (from `read` of representative PNGs)

- `lastcheck_20261127/01_donor/frame_0000.png`: top-down/isometric viewport, no HUD/chrome. Mottled olive-green grass fills the frame. Right-of-centre building cluster: large dark-timber town-hall-like hall with steep shingled roofs and red trim bands, two small thatched huts with fences, a stone windmill; a checkerboard strip of bright-green sown field tiles extends to the right frame edge. No units, no trees, no water, no minimap, no text. Camera framing identical in f1.
- `lastcheck_20261127/01_donor/frame_0001.png`: same camera/scene as f0. Differences visible: windmill sails rotated a few degrees; a group of small dark humanoid sprites (peasants) has appeared beside the mill's right hut. Field tiles, buildings, grass identical in placement. No HUD. The 99% changed-pixel statistic is therefore substantially sub-visible dither/grain across the grass, not scene motion — noted so the number is not misread as a camera or sim jump.
- `fullport6_seq2_20261113/01_donor/frame_0000.png`: same class of scene WITH full HUD: top resource bar (food/wood/stone/gold/iron/coal icons with counts, `idle 8`, `slots 0`, `units 8/200`, `score 1180`, `1x`, `Menu`), centre-top yellow hint text "Rally: right-click the map to set the gather point [R]", bottom-left "Town Hall HP 5300/5300 Rally set (451.0, 41.1)" panel with 18th-century/Rally buttons, bottom-right minimap with unit dots and white camera box. Buildings as in lastcheck; sown-field checkerboard at right. This is the only inspected deterministic frame set showing HUD/minimap/selection UI.
- `cap_fullport6.png`: no HUD. Same town-hall + two thatched huts, no windmill; two vertical columns of dark musketeer-like sprites right of the huts; one pine tree + three small figures top-left; plain grass elsewhere, no fields, no water. Different scenario/camera from the deterministic sets.

## Observations: port-internal defects vs expected-by-policy

Port-internal defects (defect detection only — none of these asserts or denies donor parity):

1. (D1) Deterministic-frame coverage collapse: 9 nominally distinct 2-frame sets across 4+ capture batches (`detcheck*`, `repcheck*`, `finalcheck*`, `finalcheck2*`, `lastcheck*`) are byte-identical (one shared SHA-256 per frame index). Re-running the harness reproduces bits but adds no new scene, camera, tick-phase, or seed coverage. Any visual defect in one instance exists in all; a second set passing adds no detection power. Flagged as a harness-capture-value defect, not a rendering defect.
2. (D2) Misleading changed-pixel signal in 2-frame sets: 99.05% changed pixels f0→f1 with mean abs diff of only ~4–5 levels and no camera shift (shift test max improvement 0.16 pp). A naive frame-diff gate would read "everything changed" while the visible scene changes are two small sprite groups. Recommend any future diff gate use tolerance/masked-ROI metrics (e.g. max-channel-diff >2 share = 71.7%, or structural comparison) rather than exact-pixel inequality. Port-internal metric-hygiene observation only.
3. (D3) Single-camera determinism: every deterministic viewport frame inspected uses one fixed camera framing of one building cluster. No alternate angle, zoom, map region, or water/shore framing exists among deterministic frames. Combined with D1, the deterministic corpus exercises exactly one viewpoint. Coverage gap, not a rendering verdict.
4. (D4) `fullport6_seq_20261113` contributes nothing: `status:"failed"` with `KeyError('seq_seconds')`, zero frames on disk. A failed set remains listed alongside passing sets; reviewers must not count set names as coverage. Minor manifest-hygiene note; no data to judge the underlying error from this read-only pass.
5. (D5) HUD present in exactly one deterministic set (`fullport6_seq2_20261113`) and absent in all 2-frame sets. HUD-vs-no-HUD rendering paths (text, panels, minimap) therefore have no deterministic repeat pair except within `fullport6_seq2` itself (no repeat manifest found for it on disk). Coverage gap for UI-layer repeatability.

Expected-by-policy (NOT defects — do not file, do not fix on the basis of this review):

- (E1) No visible water in any inspected frame (blue-dominant fraction 0.000% everywhere measured). EXPECTED under the hard-fail gate: missing water is policy-anticipated. Recorded, not defected.
- (E2) Sown-field checkerboard strip with hard tile edges (lastcheck right edge, fullport6_seq2 right edge). Stylised/placeholder field rendering is within the knownステム unfinished-art state; no parity reading is made from it here.
- (E3) Scattered pure-black pixels inside building/sprite bounds (all sets, ≤0.19%). Ordinary dark sprite/text texels, not missing-viewport or clear-colour failures. Not a defect.

## Manifest cross-check summary

- `lastcheck_20261127/manifest.json` + `repeat_verification.json` + `lastcheck_20261127_repeat/manifest.json`: all claims checked (resolution 1280x720, 2 frames, per-frame SHA-256 file+pixel, `byte_identical:true`, `parity:"UNVERIFIED"`, deterministic flags, seq_index ticks) — CONFIRMED, no discrepancies.
- `finalcheck_20261127` and `repcheck_20261113` repeat blocks carry the explicit "port-internal repeatability only; never donor parity" note — CONFIRMED present; nothing in them claims parity.
- `fullport6_seq_20261113/manifest.json` failure honestly self-reports (`status:"failed"`, KeyError, no frames) — consistent with empty directory.
- No manifest encountered claims parity, matched donor camera, or COORD status. Nothing to rebut beyond restating: none exists.

## Closing parity statements (normative, no approximations)

- Parity is UNVERIFIED. Parity chain stands at 0/6. RESULT IS NOT GOOD while `blocking_unverified` is non-empty.
- Deterministic `byte_identical=TRUE` (lastcheck, finalcheck, repcheck repeats; cross-set hash identity) is port-internal repeatability only: chain condition 6 is PARTIAL, not CLOSED.
- No donor A/B frame, no matched camera, and no COORD ruling exists in or behind this review.
- No visual observation in this report (building presence, field tiles, HUD, windmill motion, unit sprites, minimap, green-band fractions, changed-pixel percentages) promotes parity, closes any chain condition, or substitutes for a matched donor comparison.
- No approximations were used: every number above is a computed value on stated exact paths (full SHA-256 compared for identity claims; 16-hex prefixes shown only as labels where full values appear in manifests).
