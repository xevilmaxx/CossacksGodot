---
id: X39-AB-FEASIBILITY-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X39 — honest feasibility of a real donor GPU A/B frame"
role: ANALYSIS / READ-ONLY — route audit + owner procedure, no code edits, no Godot jobs
owner_file: docs/terrain_swarm_2026-11-26/reports/X39_ab_feasibility.md
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_EXECUTION__NO_DONOR_COPY__NO_GODOT_JOB
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists on disk at this pass; none is invented here. A donor frame is a NECESSARY but not SUFFICIENT condition for parity — a demonstrated match under pinned scene/seed/camera/ROI is also required. Every verdict in this report stays PORT APPROXIMATION / UNVERIFIED."
scope_guard: "Exactly one repo file written (this report). Donor install C:\\Games\\Cossacks 3 was existence-checked only (read-only) and never executed; no donor binary, map or still was copied into the repo; no source/asset/config/test/git/runner state touched; no reference image or capture was fabricated."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md — §2, §4, §6
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md — integration gates, X39 row
  - docs/terrain_swarm_2026-11-26/reports/X27_decode_coverage.md — §0, §4, §5 #10, §6 C8, §9 Q2
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md — §0, §4, §6, §7, §8
  - docs/terrain_swarm_2026-11-26/reports/V15_acceptance_without_reference.md — §2, §3, §8 Q8
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md — §2.1, §4, §7, §11
  - docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md — §12.5, §12.6, §12.7
  - docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md — §2a/§2b, claim 1/3, §7 Q1
  - docs/terrain_swarm_2026-11-26/spec/02_SEED_AND_RNG.md — §1, §4, §5
  - docs/terrain_swarm_2026-11-26/spec/07_RESOURCES.md — size enum gate
  - docs/terrain_swarm_2026-11-26/reports/F03_gen_config.md — §3.6/§7.1 (TerrainTypes)
  - docs/terrain_swarm_2026-11-26/reports/X30_season_texture_spec.md — §0 (season enum)
  - docs/terrain_swarm_2026-11-26/reports/D04_map_format.md — §0/§7 (.map loader/serializer, importer gap)
  - docs/terrain_swarm_2026-11-26/reports/D02_seed_rng.md — §4.4, §7 U1/U2
---

# X39 — Is a real donor GPU A/B frame achievable?

## 0. Executive summary

1. **[O] No route inside this project's rules can produce a donor GPU frame by the assistant or any worker.** CHARTER §4 binds every worker: "No donor executable is run, no donor binary is copied or committed. Donor material = private use only. Craft Anything read tools only." X27 §7 confirms the ceiling: no donor binary was run, no GPU frame exists, all runtime-dependent claims stay `[U]`/`PORT APPROXIMATION`. This report does not relax any guardrail.
2. **[D] Exactly one route is viable, and only because the OWNER is not a worker: the owner personally launches `C:\Games\Cossacks 3\cossacks.exe`, generates/saves a map, captures a PNG, and hands the artefact plus a written key/camera manifest to COORD.** The assistant never runs or copies the donor. This is the only route that can create the "real donor GPU A/B frame" that CHARTER §2/§6 make the precondition for any parity statement.
3. **[D] Even that route does not automatically yield a legitimate A/B.** A real donor frame is *necessary but not sufficient*: parity additionally requires a demonstrated match of scene, seed keys, size enum, map type, season, camera and ROI on both sides. Several of those inputs are `[U]` on the donor side (`GenerateMapRandKey` body, saved-map key byte mapping, sensor/FOV), so an honest owner procedure must record them rather than assume them (§3, §5).
4. **[O] The other three routes fail on their own terms.** `.map` replay gives a same-*geometry* import target only after an importer upgrade (D04 §7) and is a baked campaign snapshot, not a seed-replayable generator (F10/X27 E16); offline Godot rendering of extracted donor meshes is a port render, never a donor GPU frame (G31 §2b/§2c); the 12 third-party stills are unknown build/camera/compression and support direction-of-movement only (X07/A05 E09/spec §12.6:110-116).
5. **[O] Filesystem check this pass:** `inbox/qa/terrain_qa_report.json` and `inbox/qa/captures/` are ABSENT; `C:\Games\Cossacks 3\cossacks.exe` and `C:\Users\Maxym.Oboyshev\Downloads\c3\` are PRESENT (existence only, no execution or read of donor binary). This corroborates SWARM_BOARD's "no admissible capture; parity stays UNVERIFIED" gate.
6. **[D] Plain answer to the task's final question:** if the owner will not or cannot personally run the donor and supply the manifest, then **no route is viable** and donor parity must be reported as permanently `UNVERIFIED` (declared, accepted) — never as a gate failure, never as "donor match" (V15 §2 `declared_unverified` tier 3).

---

## 1. Evidence table

Legend: `[O]` literal file/line, filesystem fact or report statement; `[D]` consequence; `[I]` interpretation with caveat; `[U]` unverifiable under rules; `PORT APPROXIMATION` = port substitute. Donor paths are under `C:\Games\Cossacks 3\` (read-only, private use). Report paths repo-root relative.

| # | Label | Source (donor path:line or report §) | Establishes | Used for |
|---|---|---|---|---|
| E1 | `[O]` | `CHARTER.md:28-30,66-72,74-82` | Donor read-only/private use; never execute, never copy/commit donor binary; mandatory labels; no parity without real donor GPU A/B frame | Binding constraint on all routes |
| E2 | `[O]` | `CHARTER.md:41,44,125`; X27 §7; X07 §0 parity_guard | Visual acceptance target defined "without claiming parity until a real A/B GPU frame exists"; none exists | Necessity of donor frame |
| E3 | `[O]` | `SWARM_BOARD.md:233-236` integration gates; direct `Test-Path` this pass | No admissible 240²/320² capture; `inbox/qa/**` absent; parity status UNVERIFIED | Current-state baseline |
| E4 | `[O]` | `G31_donor_3d_truth.md §2a`, claim 1; `data\cameras\camera.cfg:32-35` (tilt −32 all 4 slots), `:44-45` (Min/MaxFocalLength 400), `:6-10` (SphereHeight/Length 20..58), `:51-64`; `data\cameras\default.cameras:4-18` (FocalLength 400, DepthOfView 1200, DirZ −1, UpY 1); `docreate.inc:59,94` | Main RTS view = perspective, tilt −32°, focal 400, dolly 20–58; main view takes `camera.cfg`, not the screenshot preset | Camera manifest for owner |
| E5 | `[O]/[U]` | G31 §2a, claim 3, §3 item 4, §7 Q1; `camerascreenshot.cfg:32-48` (focal 95, tilt −90…+20°, `Bounded=False`), `cameradebug.cfg:30-43` | Donor sensor/FOV unknown; 2.90° (36 mm) and 17.27° (216 mm) are both assumptions (`fov_verified=false`); separate screenshot/debug presets exist | FOV caveat; log actual profile |
| E6 | `[O]` | `A05_qa_harness.md:101-106` §2.1; `variant3d/config.json:36-71,77` (E14) | Port capture keys: pitch −32°, fov 17.27°, start_zoom 0.3448276, min/max height 20/58, pixels_per_meter 16, window 1280×720 | Port side of matched camera |
| E7 | `[O]` | `spec/02_SEED_AND_RNG.md:6-12`; D02 §0/§2; `TMapSettingsGen` map format `0x182640` | Donor has two u32 `randkey0` (high word) / `randkey1` (low word) via `SetRandomExtKey64(k0,k1)`; `GetRandomKey`→`randkey1`; port "randkey1/2" is a misnomer | Seed-key manifest |
| E8 | `[O]` | `donewgame.inc:16,33-37` (D02 E-evidence, spec/02 §1) | Map filename `game_v<ver>k<randkey1>.map`; three RNG owners seeded at `:33-35`; no player-facing seed UI (D02 §4.4) | Owner supplies keys from save/filename |
| E9 | `[U]` | D02 §7 U1; spec/02 §1/§5; X27 §5 #5; `donewgame.inc:16` | `GenerateMapRandKey` body engine-native and never located; saved-map byte→field mapping `[U]`; identity re-seed only (11 `SetRandomKey` + 3 `SetRandomExtKey64`, no `mix64`) | Blocks guaranteed same-scene replay |
| E10 | `[O]` | `donewgame.inc:42-49`; `spec/00_EVIDENCE_INDEX.md:89,178`; `spec/07_RESOURCES.md:14`; V01 EV08 | `mapsize` enum 0→320, 1→480, 2→640, 3→256 (tiny); `mapsize>2` = 256-cell tiny map | Size enum for owner |
| E11 | `[O]/[U]` | A05 §2.3 `D1` at 64²/240²/320² (E14); X27 §6 C8 (OPEN); G31 §2b (`miscext2.script:19-26` → 256/320/480/640) | Port canonical size ambiguous (240² vs 320²); donor has no 240² enum → pin donor A/B at 320² enum 0 | Multi-pass contradiction §5 |
| E12 | `[O]` | `generator.cfg:2-66`, F03 §3.6/§7.1 lines 318-358, 666-667 | TerrainTypes 0 Land (`nowater2`, `land` path commented), 1 Mediterranean, 2 Peninsulas, 3 Islands, 4 Continents, 5 Continent; DLC5 adds 6 Coastal, 7 Lakes, 8 Rivers; port `map_type=land` (A05 §2.1) | Map-type manifest; enum ↔ port mapping `[I]` |
| E13 | `[O]` | `dmscript.global:237` (`gc_MaxSeasonCount=3`); `dogenerate.inc:4,2075-2084`; X30 §0; `config.gd:129`; `data.gd:255-259` | Seasons 0 Summer, 2 Winter, 3 Desert; season 1 absent `[U]`; Spring/Autumn alias Summer; port default `gameplay.season="summer"`; Winter = name swap, Desert = different pipeline | Season manifest |
| E14 | `[O]` | `A05_qa_harness.md:168-205` §4.1/§4.2; `X07_visual_reference_index.md:234-254,256-282`; `spec/12_QA_AND_INTEGRATION.md:110-116` | G0-a…e admissibility; ground-only ROI, identical fractional ROI on both sides; stills unknown build/camera/compression → direction of movement only | Legitimacy rules |
| E15 | `[O]` | `A05_qa_harness.md:189-195,335` §4.2.3; `spec/12 §12.6:113-116` | `compare_shots.py --threshold 0.9999` legitimate only same-scene determinism; donor-vs-candidate SSIM forbidden because scenes/cameras/compression differ | Metric restriction; conditional relaxation §4 |
| E16 | `[O]` | `D04_map_format.md:16,156,263,267`; prior `import_donor_map.py` | Donor serializer `sub_739d3c`, loader `sub_73a0b8`; height-count anomaly `(W+1)²−2` vs writer `(W+1)²` `[U]` after 6 passes; current port importer emits zero `tileblock` placeholders, tile ids at record bytes 8–11 recoverable | `.map` replay route assessment |
| E17 | `[O]` | F10 §0/§2/§3; X27 E16 and §3.4 | 49 baked DLC `.map` files (2.877 GiB total DLC payload), opaque terrain payload, season integer `[U]`, deferred as campaign snapshots | `.map` replay is not generator replay |
| E18 | `[O]` | G31 §2b/§2c, claim 7/8; `terrainmesh1..4.osm` headers (2662/5305, 2272/4532, 2177/4323, 2509/5002 v/f); `yacht.oss` 311f/30fps | Donor meshes are real IDP2 assets; rendering them in Godot is a port render with Godot camera/lighting/shaders, runtime height-grid→mesh LOD `[U]` | Offline-mesh route is PORT APPROXIMATION |
| E19 | `[O]` | X07 §4/§7 U1–U11; V15 §2 three tiers; V15 §8 Q8; X07 §9 Q2 | No reference for mountains/sea/rivers/swamps/iron-coal mines; "highlands" wallpaper a 2-pass false positive; parity always UNVERIFIED; owner asked whether a genuine donor frame is obtainable at all | Still-only route ceiling |
| E20 | `[O]` | X27 §5 #1/#10; spec/00 §5 U10 | All 972 X03 `.inc` excerpts and all F03 cfg literals are `;`-prefixed intent; no donor binary was run; pass count, `hmapTex` binding, native kernels remain `[U]` | Why same seed ≠ guaranteed same scene |

---

## 2. Route analysis

Four routes were examined. Verdicts are about *what the artefact can prove*, not about how attractive it looks.

### Route A — Owner manually launches the donor and captures a matching PNG — **VIABLE, conditional (the only admissible route)**

| Aspect | Honest reading |
|---|---|
| Who runs donor | **Owner only.** Assistant/workers are forbidden (E1). This report issues no execution instruction to the assistant; §3 is written for the owner. |
| What it can prove | A genuine donor GPU pixel frame with owner-attested provenance. Necessary precondition for CHARTER §2/§6 parity statement. |
| Limitation | Same seed keys do **not** guarantee same scene: `GenerateMapRandKey` body and saved-map key bytes are `[U]`, port RNG/draw order is a `PORT APPROXIMATION` (E9/E20). Parity still requires a demonstrated match, not merely a donor PNG. |
| Route verdict | **VIABLE** if and only if the owner supplies the full manifest of §3; otherwise it degrades to a labelled donor reference frame (direction of movement only). |

### Route B — Donor replay from a `.map` file — **PARTIALLY VIABLE, not a generator A/B**

- `[O]` The donor loader/serializer pair is decoded (E16), and the port has `import_donor_map.py`; a supplied `.map` could in principle be rendered on both sides as the *same geometry* — a same-scene **rendering** A/B (A/B-L2 in §4).
- `[U]` The height-count anomaly and tag/owner/collision field semantics are unresolved after 6 passes (D04 U1–U8); the current importer emits zero tile ids (E16) so a COORD-owned upgrade is required before any comparison.
- `[O]` The shipped 49 DLC maps are baked campaign snapshots with opaque payload and `[U]` season (E17); they are not seed-replayable generated terrain. A `.map` replay cannot test whether our *generator* matches the donor generator.
- **Verdict:** admissible only as a same-geometry rendering comparison after owner supplies the map outside the repo and COORD upgrades the importer; **never** a substitute for Route A on generation parity.

### Route C — Extracted donor meshes rendered offline in Godot — **NOT DONOR PARITY, inadmissible as donor A/B**

- `[O]` Donor `terrainmesh1..4.osm` and unit meshes are real assets (E18); rendering them in Godot uses Godot's camera, lighting, shaders and (for terrain) our height grid.
- `[D]` This tests asset conversion and self-consistency only — exactly V15 tier 1/2 (`Port Approximation`). It cannot certify the donor renderer, camera, blend pass count or water binding, all of which stay `[U]` (E18/E20).
- **Verdict:** useful engineering evidence; explicitly **not** a donor GPU A/B frame. Must be labelled `PORT APPROXIMATION`.

### Route D — Reference stills only — **INSUFFICIENT BY DEFINITION**

- `[O]` Unknown donor build, camera, zoom, world area per pixel and JPEG/WEBP compression (E14/E19); no ROIs are calibrated world-space regions.
- `[O]` No reliable still for five classes; "highlands" is a 2-pass false positive; `parity.status` always UNVERIFIED (V15 §2/§6).
- **Verdict:** direction of movement only; never a numeric gate, never parity (X07 §6 risk 1; A05 §4.2.2).

### Route summary

| Route | Produces real donor GPU frame? | Same scene guarantee? | Admissible as parity evidence? |
|---|---|---|---|
| A — owner-run capture | **Yes** (owner supplies) | Only if manifest matched; seed≠scene under `[U]` keys | Necessary precondition; sufficient only after proven match |
| B — `.map` replay | No new donor frame unless owner also captures | Yes for geometry, after importer fix | Rendering A/B only, not generator parity |
| C — offline Godot meshes | No | No | No — PORT APPROXIMATION |
| D — stills | No | No | No — direction of movement only |

---

## 3. Exact owner procedure for the viable route (Route A)

**Audience: OWNER. The assistant/workers execute none of this.** Every artefact stays outside the repo; no donor binary, `.map`, or donor PNG is ever copied or committed (E1). All paths below are Windows paths; use `python`, not `python3` (CHARTER §4 "Windows").

### Step 1 — Choose the target configuration *before* launching the donor

Pin these values and write them into a plain-text manifest. Each has a cited source in §1:

| Field | Value to record | Authority / caveat |
|---|---|---|
| Size | `mapsize = 0` → **320×320** grid | `donewgame.inc:42-49` (E10). Do **not** use 240²: there is no donor enum for it (E11). Port's 64² is a port-only determinism fixture. |
| Map type | Donor `TerrainTypes` **0 Land** (`nowater2`) — the closest match to port `gameplay.map_type = "land"` | `generator.cfg:2-66` (E12); enum↔port mapping is `[I]`, record whichever other enum the owner actually selects if different. |
| Season | Integer **0 Summer** (or 2 Winter / 3 Desert if deliberately testing those) | X30 §0 (E13). Record entitlement state; season 1 absent, Spring/Autumn alias Summer. |
| Seed keys | `randkey0` = ______ (u32, high word), `randkey1` = ______ (u32, low word) | D02/spec/02 §1 (E7/E8). `randkey1` is embedded in the save filename `game_v<ver>k<randkey1>.map`; `randkey0` and the byte-offset mapping are `[U]` (E9) — supply both ints explicitly, do not infer them. |
| Camera profile | Main view uses `data\cameras\camera.cfg`; note if a different profile (`camerascreenshot.cfg`, `cameradebug.cfg`) was selected | G31 §2a / E4/E5. |
| Camera values | tilt **−32°** (`camera.cfg:32-35`), focal **400** (Min=Max, `:44-45`), dolly/SphereHeight/SphereLength **20…58** (`:6-10`), DepthOfView **1200** (`default.cameras:4-18`); record actual in-game zoom/dolly at capture | E4. Donor absolute FOV/sensor is `[U]` (E5); port uses fov 17.27° as an assumption. |
| Window | 1280×720, windowed (no fullscreen scaling), no HUD over the ROI if achievable | A05 G0-a…e (E14). |
| Donor build | Game/data version string (`gDataVersion`) and install path `C:\Games\Cossacks 3` | `donewgame.inc:37` names version in filename (E8). |

Port-side capture keys to mirror (COORD, not owner, sets these): `pitch_degrees=-32`, `fov_deg=17.27`, `start_zoom=0.3448276`, `min_height/max_height=20/58`, `pixels_per_meter=16`, `window=[1280,720]` (E6); explicit absolute config overlay, never ambient config (A05 §2.1).

### Step 2 — Launch and generate (owner action only)

1. Start the donor normally from its own install (`C:\Games\Cossacks 3`); do **not** copy or move any donor binary.
2. Start a skirmish/new game with the Step-1 settings. The donor has no player-facing numeric seed UI (`GenerateMapRandKey` runs at `donewgame.inc:16`, E8/E9), so the seed keys are whatever the donor generated — read `randkey1` from the saved map filename and copy both u32 integers into the manifest from the game's own state/log if available; if `randkey0` cannot be read, mark it `UNKNOWN` and the comparison is A/B-L2-or-direction-only (§4).
3. Save the generated `.map` **outside the repo** (e.g. `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.map`). This preserves the exact scene for a possible same-geometry Route-B comparison. Do not place it under the repository tree.

### Step 3 — Capture the donor PNG outside the repo

1. Position the camera to the Step-1 values; let the frame settle (no unit selection panel, no HUD tooltip over the intended ROI).
2. Save a full-resolution PNG to an **owner-controlled directory outside the repo**, recommended:
   `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.png`
   (Do not reuse the X07 still folder as "evidence"; those are third-party and confounded, E19.)
3. Record verbatim in the manifest: capture timestamp, window size, camera profile, tilt/focal/dolly actually used, the saved `.map` filename, and a SHA-256 of the PNG.

### Step 4 — Provide the key/camera/ROI manifest to COORD

Hand COORD the manifest plus the two out-of-repo artefacts (`.map`, PNG). COORD then (a) pins the port key manifest and explicit overlay, (b) produces the port PNG via the single legal Godot path `python variant3d\tools\godot_runner.py run --id x39-ab-<unique> ...` with a **unique id**, into a temp directory outside the repo, e.g. `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\x39_ab\port_320_land_summer.png` (A05 `<T>` convention), and (c) verifies G0-a…e (windowed, non-blank 1280×720, `script_error_lines = 0`, pinned seed/camera/size, `assert_clean` clean) before any read (E14; A05 §8 planned commands 325-328). **This worker submits no Godot job.**

### Step 5 — ROI and comparison

1. Pick a ground-only fractional ROI on-screen and apply the **same** `(x0,y0,x1,y1)` to both donor and port PNG. Safe starting point: A11 ref A `.35,.55,.48,.70` (X07 §5/A05 §4.2), but re-verify it lands on ground, not HUD/units/sky, in *both* frames; if it lands on a different feature, the comparison is UNVERIFIED — do not rerun until green (G0-e, E14; X07 §6 risk 7).
2. Confirm `compare_shots.py --crop-frac` uses the same ordering on both sides (X07 §9 Q5).
3. Use `terrain_ab_metric.py ... --crop-frac <roi>` for distribution/direction hints; use `compare_shots.py --threshold 0.9999` **only** under the proven-match conditions of §4 (otherwise it remains self-determinism-only per E15).
4. Keep `metric_field` and `visual_field` separate in `terrain_qa_report/1`; write `parity.claim = NONE` and `parity.status = UNVERIFIED` until COORD explicitly rules a demonstrated match (A05 §7; V15 §6).

**Owner must provide, in one line each:** size enum; map type enum; season int; `randkey0`/`randkey1` (or mark `UNKNOWN`); camera profile + tilt/focal/dolly + actual zoom at capture; donor build version; saved `.map` path (out of repo); donor PNG path (out of repo) + SHA-256; ROI `(x0,y0,x1,y1)` confirmed ground-only on both sides; written attestation "donor launched by owner; assistant never executed donor".

---

## 4. Legitimacy criteria

### What counts as a legitimate A/B

Two levels, both requiring a real owner-supplied donor GPU PNG with provenance and a labelled pair:

**A/B-L1 — input-matched generator comparison.** Same seed keys (`randkey0/1`), same size enum, same map type, same season, same pinned camera values, same fractional ROI, both sides generated/rendered; each side labelled `DONOR (owner-run)` / `PORT (candidate)`; manifest + hashes recorded. Legitimate as a **matched-input** comparison. Because donor key derivation, draw order and runtime activation are `[U]` (E9/E20), L1 proves divergence if frames differ; it does **not** certify parity even if they look similar, unless a byte-identical geometry + pixel-identical frame match is demonstrated.

**A/B-L2 — scene-matched rendering comparison.** The owner's saved `.map` is imported into the port (after the D04 §7 importer upgrade) so both sides render the same geometry; same camera/ROI; labelled. Legitimate as a **rendering** A/B, but it tests rendering, not generation.

Common admissibility (all mandatory): G0-a…e (E14); ground-only identical ROI verified on both sides (G0-e); metric and prose in separate fields; reviewer line verbatim:
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

Note the reviewer line says "No donor GPU A/B frame exists" as the current state; once the owner supplies one, COORD must update that line to "Donor frame supplied by owner; parity still UNVERIFIED pending demonstrated match" — this report does not make that transition itself.

**Necessary vs sufficient.** `[D]` A real donor frame is necessary (CHARTER §2/§6) but not sufficient. Parity requires, in addition, (i) an honest manifest proving matched scene/seed/camera/ROI and (ii) a demonstrated match. Until COORD rules (ii), `parity.status = UNVERIFIED` even with a donor PNG on disk.

### What remains only direction of movement (never parity)

- Any comparison against X07's 12 stills — unknown build/camera/compression (E14/E19).
- A donor PNG whose seed keys, size enum, map type, season, camera profile or ROI are unknown/unmatched (including `randkey0 = UNKNOWN`).
- Route C (offline Godot render of donor meshes) — port render, PORT APPROXIMATION.
- Route B before importer upgrade / with baked DLC maps — not a generator test.
- `terrain_ab_metric.py` z-scores / `outside_donor_range` flags — calibration hints only (A05 §4.2.2).
- `compare_shots.py` SSIM/MAD unless A/B-L1 or L2 is proven; a green number cannot erase a visible ring/vein/grid (A05 §4.2.4; V15 §2).
- A "matched seed" where port geometry differs because of `[U]` runtime activation — informative for *direction* of divergence only.

### Explicitly forbidden

Whole-frame vs cropped-donor comparison; "donor match/parity/confirmed" wording; using the 0.80 `compare_shots.py` default as a gate; dropping a region to hide an artifact; rerunning until green (A05 §4.2/§6); committing donor binary, `.map` or still; assistant executing donor (E1).

---

## 5. Multiple passes on contradictions (owner directive, CHARTER §4)

Each contradiction was re-read with ≥2 instruments/readings; accepted reading is stated, nothing silently skipped.

| # | Contradiction | Passes | Accepted reading | Label |
|---|---|---|---|---|
| P1 | "randkey1/2" (A02, port) vs `randkey0`/`randkey1` (donor) | 1: A02 §0/§E01 uses randkey1/2; 2: D02 §0 binary `TMapSettingsGen` schema + spec/02 §1; 3: C8 refutes mix64 | Donor = two u32, `randkey0` high / `randkey1` low; port pair is a misnomer; identity re-seed, no `mix64` | `[O]` + PORT APPROXIMATION |
| P2 | Canonical capture 240² (config.json:75-76) vs 320² (small_map_64.json:6) vs donor enum sizes | 1: A05 E14 both literals; 2: X27 §6 C8 = OPEN; 3: G31 §2b `miscext2.script:19-26` = 256/320/480/640; 4: `donewgame.inc:42-49` | 240² is port-only determinism size; **donor A/B pinned at 320² (enum 0)**; canonical-size question stays OPEN for COORD | `[O]` + `[U]` |
| P3 | FOV 2.90° vs 17.27° | 1: G31 §3 36 mm→2.90°; 2: M0.6 216 mm→17.27°; 3: G31 claim 3 `fov_verified=false` | Both are assumptions; donor absolute FOV `[U]`; port uses 17.27°, must be recorded as such | `[U]` |
| P4 | `camera.cfg` main view vs `camerascreenshot.cfg` (focal 95, tilt −90…+20°) | 1: G31 §2a camera values; 2: `docreate.inc:59,94` main view takes `camera.cfg`; 3: G31 §2a presets listed as separate | Main skirmish view = `camera.cfg`; screenshot/debug presets are distinct — owner must log which was used | `[O]` |
| P5 | `mapsize>2` "large" (D07 example) vs 256-cell tiny (V01) | 1: D07 §3.4 example; 2: V01 EV08 `donewgame.inc:42-46`; 3: spec/07 + V12 C-V3 | enum 3 = 256-cell **tiny**; do not relabel or promote 320 example | `[O]` |
| P6 | Stills as "donor A/B" vs third-party confounds | 1: X07 §4 class map; 2: A05 E09 / spec §12.6 unknowns; 3: X07 A6 "highlands" 2-pass false positive | Stills = direction only; no parity, no numeric gate | `[O]`/`[U]` |
| P7 | A02 `mix64` per-stage keys vs donor identity reseed | 1: A02 §Stage0 mix64; 2: V01 P1/P2 + C8; 3: spec/02 §5 | Identity reseed at 11+3 sites; mix64 is a divergent PORT APPROXIMATION | `[O]` + PORT APPROXIMATION |
| P8 | "Spring/Autumn/season 1" vs 3 real seasons | 1: 124-id/4-name presets reading; 2: X30 §0 `gc_MaxSeasonCount=3`, ints 0/2/3; 3: F10 alias evidence | Season 1 `[U]` absent; Spring/Autumn alias Summer; Winter name-swap, Desert different pipeline | `[O]`/`[U]` |
| P9 | A05 §4.2.3 forbids donor-vs-candidate SSIM vs "matched donor frame makes SSIM meaningful" | 1: A05/E15 prohibition premised on different scenes/cameras/compression; 2: the premise is removed only if A/B-L1/L2 is proven; 3: V15 tier vocabulary has no parity tier | Conservative: keep `compare_shots.py` self-determinism-only until COORD proves a matched frame; then its use is a documented `[I]` decision, not this worker's claim | `[I]` + `[U]` |

---

## 6. UNVERIFIED register

| id | Item | Basis | What would settle it |
|---|---|---|---|
| U1 | Existence of a donor GPU A/B frame | Test-Path this pass ABSENT; SWARM_BOARD gate; A05 §11; V15 Q8; X07 Q2 | Owner supplies Route A PNG + manifest |
| U2 | `GenerateMapRandKey` body / key derivation | D02 U1; X27 §5 #5; spec/02 §1 | Owner supplies explicit `randkey0/1`; deeper binary RE is out of today's rules |
| U3 | Saved-`.map` byte→`randkey0/1` mapping | D02 U2; no known-key generated map shipped | Owner reads both ints from game state/log; or a known-key map is supplied |
| U4 | Donor absolute FOV / sensor constant | G31 claim 3 / §7 Q1; both 2.90° and 17.27° assumed | Owner logs actual camera state and camera profile at capture |
| U5 | Canonical size 240² vs 320² | X27 §6 C8 OPEN; no donor 240² enum | COORD pins 320² (enum 0) for donor A/B; 240² stays port-only |
| U6 | Port `map_type="land"` ↔ donor TerrainTypes enum 0 | F03 §3.6; port A05 §2.1 | Owner records exact enum; mapping accepted as `[I]` until compared |
| U7 | Season entitlement actually installed | X30 U-1; `showcustomgame.inc:43-54` | Owner states entitlement/selected season explicitly |
| U8 | Camera state (zoom/dolly/tilt) at the owner's capture | No donor runtime frame exists to read it from | Owner writes it into the manifest at capture time |
| U9 | `.map` importer emits real tile ids | D04 §7 zero `tileblock` placeholders; height-count anomaly `[U]` | COORD-owned importer upgrade + byte validation |
| U10 | Baked DLC map payload / season values | F10 §0/§2/§3; X27 E16 | Out of scope for generator A/B; do not use as seed evidence |
| U11 | Runtime activation of `;`-prefixed donor scripts | X27 §5 #1; spec/00 U10 | Cannot be settled under read-only rules; same seed ≠ same scene |
| U12 | Owner willingness/ability to run donor | V15 Q8 / X07 Q2 unanswered | Owner decision; if negative, parity stays permanently UNVERIFIED |
| U13 | Donor height-grid → mesh LOD connector | G31 §2b / §7 Q2 | Not settled by a single capture; affects rendering verdict only |

---

## 7. Open questions

1. **Q1 (OWNER):** Will you personally launch `C:\Games\Cossacks 3\cossacks.exe` and supply the Route A PNG + `.map` + manifest (§3)? If no, parity is permanently UNVERIFIED and the honest owner verdict is `RESULT IS NOT GOOD while blocking_unverified is non-empty` with `internal consistency PASS / donor parity UNVERIFIED` (V15 §6, superseded by owner guard: no unqualified RESULT IS GOOD).
2. **Q2 (COORD):** Confirm size pin = 320² donor enum 0, with 240² retained as a port-only determinism atom (P2/U5).
3. **Q3 (COORD):** Can `randkey0/1` be read from the owner's map/game state, or must the comparison be downgraded to A/B-L2 with `randkey0 = UNKNOWN` (U2/U3)?
4. **Q4 (COORD):** Approve the A/B-L1 vs A/B-L2 distinction and the rule "donor frame necessary but not sufficient for parity" (§4)? Without approval, `parity.status` stays UNVERIFIED on principle.
5. **Q5 (OWNER/COORD):** Which camera profile was used, and can the actual tilt/focal/dolly/zoom be logged at capture to reduce the FOV assumption (U4/P3/P4)?
6. **Q6 (COORD):** Who owns the `.map` importer upgrade (D04 §7) needed for A/B-L2, and what policy handles the height-count anomaly?
7. **Q7 (COORD):** At what evidence threshold, if any, may a donor frame be paired with a port frame under `compare_shots.py` (P9)? Recommendation here: only after A/B-L1/L2 is proven and COORD signs the change.
8. **Q8 (COORD):** Where exactly will out-of-repo donor artefacts live, and how will their hashes be recorded without committing donor material (E1)?

---

## 8. Five-line summary (for COORD)

1. **[O] No worker/assistant route can produce a donor GPU frame:** donor execution and copying are forbidden by CHARTER §4, and no frame exists on disk (Test-Path + SWARM_BOARD gate); no parity claim is made.
2. **[D] Only one route is viable — the OWNER personally runs the donor** at 320² (enum 0), Land/TerrainTypes 0, pinned season and explicit `randkey0/1`, logs tilt −32°/focal 400/dolly 20–58 and camera profile, and supplies an out-of-repo `.map` + PNG + manifest.
3. **[D] A donor PNG is necessary but not sufficient:** `GenerateMapRandKey`, saved-map key bytes, donor FOV and script runtime activation are `[U]`, so same seed keys do not guarantee same scene; parity needs a demonstrated match under matched scene/seed/camera/ROI, labelled, with metric and visual fields separate.
4. **[O] The other routes fail:** `.map` replay is a baked-snapshot/rendering-only comparison pending an importer upgrade (D04 §7, F10); offline Godot meshes are PORT APPROXIMATION (G31); the 12 stills are unknown build/camera/compression → direction of movement only (X07/A05/spec §12.6).
5. **[D] If the owner declines, no route is viable and parity stays permanently UNVERIFIED** — report "gates green / internal consistency PASS / donor parity UNVERIFIED", never "donor match"; multi-pass contradictions (240²/320², randkey0/1, FOV, camera profile, size enum, still admissibility) are recorded in §5 with no silent resolutions.

*End of X39 report. Exactly one repo file written; no donor executable executed or copied; no Godot job, gate, capture, source, asset, config, test or git edit; no invented frame, metric or donor-parity claim.*
