---
id: OWNER-CAPTURE-TEMPLATE-V92
swarm: TERRAIN-SWARM-2026-11-26
role: FILL-IN FORM — owner-run donor capture for a same-camera A/B (X39 Route A); no execution, no donor access, no capture produced here
worker: V92 (30-agent DONOR-FIRST terrain swarm)
owner_file: inbox/qa/OWNER_CAPTURE_TEMPLATE.md
status: TEMPLATE__UNFILLED__NO_CAPTURE__NO_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_claim: false
parity_status: UNVERIFIED
scope_guard: "Exactly ONE new repo file written (this template). No donor binary executed, no donor file copied/committed, no Godot/runner job submitted, no code/Godot/git/donor write, no reference image or capture fabricated. All fields below are BLANK; the owner must fill them. No source, asset, config, test, gate or report was edited."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md — §2, §4 (read-only donor, labels, multiple passes), §6
  - docs/terrain_swarm_2026-11-26/reports/X39_ab_feasibility.md — §2 Route A, §3 (owner procedure), §4 (A/B-L1/L2), §5 (multi-pass P1–P9), §6 U1–U13, §7 Q1
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md — §4.10 (fresh windowed 320² capture form), §3 (flag matrix), §4 conventions
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md — §2.1 (key/capture manifest), §4.1 (G0-a…e), §4.2 (metric legitimacy), §7 (terrain_qa_report/1)
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md — §4, §5 (ROI convention), §6 (confounds), §7 U1/U7, §8 (reviewer line)
  - docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md — §12.5, §12.6, §12.7
---

# OWNER CAPTURE TEMPLATE — same-camera donor A/B (X39 Route A)

## 0. What this is / what it is not

**[D]** This is a **blank fill-in form** for the OWNER to personally run the donor and hand COORD a legitimate, provenance-backed same-camera A/B pair. It is the paperwork half of X39 Route A — the only admissible route, because workers/assistants may not execute or copy the donor (`CHARTER.md:28-30,66-72`; `X39 §2` Route A; `X39 §3`).

- **No field is pre-filled. No capture, PNG, `.map`, hash, metric or ROI value is invented here.** Every `______` must be written by the owner at capture time.
- **No donor parity claim.** A donor GPU frame is *necessary but not sufficient* for parity: parity additionally needs a demonstrated match of scene/seed/camera/ROI (`X39 §4:178`, `X39 §1 E9/E20`). Until COORD explicitly rules a match, `parity.claim = NONE` and `parity.status = UNVERIFIED`.
- **The assistant/worker executes none of §1–§3 below.** Only the owner launches the donor; only COORD submits the port capture job (`X39 §3:115,150`; `CHARTER.md:82`).

---

## 1. PREREQUISITES — pin these BEFORE launching the donor

Each row carries its cited authority. Fill the "Owner value" column; do not infer a value the sources mark `[U]`.

| # | Prerequisite | Required value to pin | Authority / caveat | Owner value |
|---:|---|---|---|---|
| P1 | Donor install present, owner-run | `C:\Games\Cossacks 3\cossacks.exe` launched by **owner only** from its own install; do **not** copy/move the binary | `CHARTER.md:28-30,66-70`; `X39 §3 Step 2:136` | ______ |
| P2 | Map size | `mapsize = 0` → **320×320** grid. Do **not** use 240² — donor has no 240² enum | `donewgame.inc:42-49` (`X39 E10`); 240²/320² contradiction `X39 §5 P2` / `U5` | ______ |
| P3 | Land shape / map type | Donor `TerrainTypes` **0 Land** (`nowater2`) — closest to port `gameplay.map_type = "land"` | `generator.cfg:2-66`, F03 §3.6/§7.1 (`X39 E12`); enum↔port mapping is `[I]` — record the actual enum if different | ______ |
| P4 | Season | Integer **0 Summer** (or 2 Winter / 3 Desert if deliberately testing); state entitlement. Season 1 absent `[U]`; Spring/Autumn alias Summer | `dmscript.global:237`, `dogenerate.inc:4,2075-2084`, X30 §0 (`X39 E13`); `X39 §5 P8` | ______ |
| P5 | Seed keys — explicit | `randkey0` = ______ (u32, **high** word); `randkey1` = ______ (u32, **low** word). Supply both ints; do **not** infer. `GenerateMapRandKey` body and saved-map byte mapping are `[U]` — if `randkey0` cannot be read, write `UNKNOWN` and the comparison degrades to direction/A-B-L2 only | spec/02 §1, D02 §0/§2 (`X39 E7`); `donewgame.inc:16,33-37` (`X39 E8`); `X39 E9`, `§5 P1`, `§6 U2/U3` | `randkey0` ______ / `randkey1` ______ |
| P6 | Camera profile name | Main skirmish view = `data\cameras\camera.cfg`; note if `camerascreenshot.cfg` or `cameradebug.cfg` was selected instead | G31 §2a, `docreate.inc:59,94` (`X39 E4/E5`, `§5 P4`) | ______ |
| P7 | Camera values | tilt **−32°** (`camera.cfg:32-35`); focal **400**, Min=Max (`:44-45`); dolly / SphereHeight / SphereLength **20…58** (`:6-10`); DepthOfView **1200** (`default.cameras:4-18`). Record the **actual in-game zoom/dolly at capture**. Donor absolute FOV/sensor is `[U]` | G31 §2a (`X39 E4/E5`, `§5 P3`, `§6 U4/U8`) | ______ |
| P8 | Window | **1280×720, windowed** (no fullscreen scaling); no HUD/tooltip over the intended ROI | A05 G0-a…e (`X39 E14`) | ______ |
| P9 | Donor build/version | Game/data version string (`gDataVersion`) and install path | `donewgame.inc:37` (`X39 E8`) | ______ |
| P10 | Port-side keys to mirror (COORD sets, not owner) | `pitch_degrees=-32`, `fov_deg=17.27`, `start_zoom=0.3448276`, `min/max_height=20/58`, `pixels_per_meter=16`, `window=[1280,720]`; explicit config overlay, **never** ambient config. `fov_deg=17.27` is a documented assumption `[U]`, not a verified donor sensor | A05 §2.1, `config.json:36-71,77` (`X39 E6`, `§5 P3`) | ______ |

**Multi-pass note on these parameters (owner directive, `CHARTER.md:85-93`).** Each contested value was re-read with ≥2 instruments; accepted readings are recorded, nothing silently skipped (`X39 §5`):

| Parameter | Passes | Accepted reading | Label |
|---|---|---|---|
| Size 240² vs 320² | `config.json:75-76` (240²) · `small_map_64.json:6` (320² prose) · `donewgame.inc:42-49` · X27 §6 C8 OPEN | 240² = port-only determinism atom; **donor A/B pinned at 320² (enum 0)** | `[O]` + `[U]` |
| `randkey0/1` vs "randkey1/2" | A02 port misnomer · D02 binary `TMapSettingsGen` · spec/02 §1 · C8 refutes `mix64` | Donor = two u32 (high/low); identity reseed at 11+3 sites; no `mix64`; port pair a misnomer | `[O]` + PORT APPROXIMATION |
| FOV 2.90° vs 17.27° | G31 36 mm→2.90° · M0.6 216 mm→17.27° · G31 `fov_verified=false` | **Both assumptions**; donor absolute FOV `[U]`; port uses 17.27° and must log it as such | `[U]` |
| `camera.cfg` vs screenshot/debug presets | G31 §2a · `docreate.inc:59,94` · G31 preset list | Main view = `camera.cfg` (focal 400, tilt −32); screenshot preset (focal 95, tilt −90…+20°, `Bounded=False`) and debug preset are distinct — owner must name the one used | `[O]` |
| Season 1 / Spring / Autumn | 124-id/4-name presets · X30 §0 `gc_MaxSeasonCount=3` · F10 alias evidence | Season 1 `[U]` absent; Spring/Autumn alias Summer; Winter name-swap, Desert different pipeline | `[O]`/`[U]` |
| Stills as donor A/B | X07 §4 class map · A05 E09/spec §12.6 unknowns · X07 A6 "highlands" 2-pass false positive | Stills = direction of movement only; no parity, no numeric gate | `[O]`/`[U]` |

---

## 2. EXACT FIELDS TO RECORD — owner fills at capture time

Write one value per line. Keep all artefact paths **OUTSIDE the repository tree** (§4). Do not copy donor files into the repo.

### 2.1 Artefact manifest

| Field | Owner entry |
|---|---|
| Donor build / version (`gDataVersion`) | ______ |
| Donor install path | `C:\Games\Cossacks 3` (confirm: ______) |
| `mapsize` enum + resulting grid | enum ______ → ______ × ______ (expect 0 → 320×320) |
| Map type enum / name | ______ (expect 0 Land / `nowater2`) |
| Season integer / name | ______ (0 Summer / 2 Winter / 3 Desert) |
| `randkey0` (u32 high word, or `UNKNOWN`) | ______ |
| `randkey1` (u32 low word, from save filename `game_v<ver>k<randkey1>.map`) | ______ |
| Saved `.map` path **OUTSIDE repo** (recommended `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.map`) | ______ |
| Donor PNG path **OUTSIDE repo** (recommended same folder, `...donor_320_land_summer_k<randkey1>.png`) | ______ |
| Camera profile name actually used | ______ (`camera.cfg` / `camerascreenshot.cfg` / `cameradebug.cfg`) |
| Camera tilt actually used (deg) | ______ (pin −32) |
| Focal length actually used | ______ (pin 400) |
| Dolly / SphereHeight / SphereLength actually used | ______ … ______ (pin 20…58) |
| DepthOfView actually used | ______ (pin 1200) |
| Actual in-game zoom at capture | ______ |
| Window size / mode | ______ × ______ (pin 1280×720 windowed) |
| Capture timestamp (local, with offset) | ______ |
| SHA-256 of saved `.map` | ______ |
| SHA-256 of donor PNG | ______ |
| ROI rectangle `(x0,y0,x1,y1)`, fractional, ground-only **on both sides** | ______ (safe starting point `.35,.55,.48,.70` — re-verify on ground, not HUD/units/sky, in **both** frames) |

### 2.2 Hash command for the owner (run on the out-of-repo artefacts only)

```powershell
Get-FileHash "C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.map","C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.png" -Algorithm SHA256
```

`[O]` `Get-FileHash -Algorithm SHA256` is the same instrument used in `V42 §4.5/§4.10:272` for the port freeze manifest; the two hashes are recorded as manifest values, **not** by committing the files.

### 2.3 Owner attestation (verbatim line — required)

> "Donor launched by owner from `C:\Games\Cossacks 3`; assistant/worker never executed or copied the donor; artefacts stored outside the repository; no redistribution."

Owner signature / date: ______

---

## 3. MATCHING PORT CAPTURE — placeholder only (COORD runs it)

**[D]** Owner does **not** run this. COORD, after receiving the §2 manifest and the two out-of-repo artefacts, pins the port key manifest + explicit 320² overlay and submits **one** fresh windowed capture via the single legal Godot path, with a **unique id** (`X39 §3 Step 4:150`; `V42 §4.10:254-259`; `CHARTER.md:80-82`). `<UNIQUE>` = a fresh id chosen by COORD (e.g. `x39-ab-01`); `<T>` = an owner/COORD temp dir **outside the repo** (e.g. `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\x39_ab`); `<PORT_SEED>` = the pinned port `gameplay.random_seed` (its mapping to donor `randkey0/1` is `[U]` — do not assert equivalence, `X39 E9`).

```powershell
# COORD only — template, NOT a submitted job. One Godot at a time; call godot_runner.py status after the run.
python variant3d\tools\godot_runner.py run --id x39-ab-<UNIQUE> --timeout 700 --max-wait 3600 -- --path variant3d -- --config "<T>\x39_ab_map_320.json" --screenshot "<T>\x39_ab_port_320.png" --screenshot-frames 10 --seed <PORT_SEED> --timeout 600
python variant3d\tools\godot_runner.py status
```

**Rules for this placeholder** (source-verified, `V42 §3/§4.10`, `X39 §3 Step 4`):

- No `--headless` (headless writes the 800×600 CPU fallback); `--screenshot-frames 10` selects the real viewport path; `--timeout 600` after the second `--` overrides the 120 s watchdog; runner `--timeout 700` must exceed it; never combine with `--dump-config` (`V42:264`).
- The overlay `x39_ab_map_320.json` must explicitly pin `map_width_tiles=320`, `map_height_tiles=320` and the P10 capture keys; ambient config is forbidden (`A05 §2.1:107-109`).
- Output PNG under `<T>` **outside the repo**; freeze + `Get-FileHash -Algorithm SHA256` before any read (`V42 §4.10:266-272`).
- **Admissibility G0-a…e before any number counts** (`A05 §4.1:168-175`; `X39 E14`): windowed launch; PNG exists 1280×720, non-blank; capture diag `camera_current=true`, `world_parent=Screenshot3DViewport`; `scan-stderr.script_error_lines = 0`; seed/camera/size/config pinned and recorded; ground-only ROI chosen and **the same fractional ROI applied to both sides**. A failed sub-item makes the comparison UNVERIFIED — do not substitute green JSON or rerun until green.

---

## 4. PRIVACY GUARD — binding

1. **Never copy donor files into the repo.** No donor binary, `.map`, PNG, still, or extracted asset is placed under the repository tree or committed (`CHARTER.md:28-30,66-70`; `X39 §3:115,138,143-146`; `X39 E1`). The repo receives only this blank template and the manifest values (paths + hashes), never the artefacts themselves.
2. **Never redistribute donor material.** Donor material is **private use only** (`CHARTER.md:30,69`; `X39 §2`). Do not share, upload, forward or publish the donor `.map`/PNG or any derived crop outside the owner-controlled directory.
3. **Assistant/workers never execute the donor** (`CHARTER.md:28-29`; `X39 §2 Route A`, `§3`). Only the owner launches it.
4. **Do not reuse the X07 third-party still folder as "evidence"** — those 12 images have unknown build/camera/compression and are confounded (`X07 §0, §6`; `X39 §3 Step 3:145`).
5. Hashes are recorded as **text manifest values** only; this template records no bytes, no donor constants, no synthetic frame, no invented ROI or metric.

---

## 5. EXACT COMPARISON PROTOCOL — what a filled form permits and forbids

### 5.1 Matched-input prerequisites (all mandatory)

Same **scene**, same **seed keys** (`randkey0/1`), same **size enum** (320, enum 0), same **map type** (Land), same **season**, same **camera values/profile**, same **fractional ROI**, both sides labelled `DONOR (owner-run)` / `PORT (candidate)`, manifest + SHA-256 recorded (`X39 §4:167-173`). Each side must be independently admissible (§3 G0-a…e).

### 5.2 Legitimate comparison levels (`X39 §4`)

- **A/B-L1 — input-matched generator comparison.** All §5.1 inputs matched on both sides. Legitimate as a **matched-input** comparison. Because donor key derivation, draw order and runtime activation are `[U]` (`X39 E9/E20`), a difference proves divergence; a visual similarity **does not certify parity** unless a byte-identical geometry + pixel-identical frame match is demonstrated.
- **A/B-L2 — scene-matched rendering comparison.** Owner's saved `.map` imported into the port (after the D04 §7 importer upgrade) so both sides render the same geometry; same camera/ROI. Legitimate as a **rendering** A/B — tests rendering, **not generation**. Needed when `randkey0 = UNKNOWN`.
- Common admissibility for both: G0-a…e (§3); ground-only identical ROI verified on both sides; **metric and prose in separate fields** (`A05 §7:276-284`).

### 5.3 Metrics — direction of movement only, until a match is demonstrated

- Use `terrain_ab_metric.py <png> --compare-ref <ref> --crop-frac <roi> --json --per-file` for **distribution / direction hints** only: `distribution`, `z`, `outside_donor_range`, `flags` are calibration prompts, not verdicts (`A05 §4.2.2:186-188`, `§11`; `V42 §4.10:280`). Advisory bands from A11/G21 (BV32 n640 ≈150–270, grad ≈1–2, luma std ≈18–22, sat ≈0.53 secondary) are **direction only**, never gates, never parity (`A05 E09`, `§4.2.1:181-185`).
- `compare_shots.py --threshold 0.9999` is legitimate **only** for candidate-vs-candidate self-determinism at a pinned camera; donor-vs-candidate SSIM/MAD is **forbidden** because scenes/cameras/compression differ (`A05 §4.2.3:189-193`, E12/E15; `spec §12.6:110-116`). Its 0.80 default is a smoke placeholder, not a gate (`V42 §3:79`).
- Ground-only ROI must be re-verified in **both** frames; if it lands on a different feature (HUD/units/sky), the comparison is UNVERIFIED — do not relocate to hide an artifact or rerun until green (`X07 §6 risk 7`; `A05 §4:200-205`).

### 5.4 Parity verdict — no claim until demonstrated match

- **A donor PNG is necessary but not sufficient.** Parity needs (i) an honest manifest proving matched scene/seed/camera/ROI and (ii) a **demonstrated match**; until COORD rules (ii), `parity.status = UNVERIFIED` even with a donor PNG on disk (`X39 §4:178`).
- Until then write `parity.claim = NONE`, `parity.status = UNVERIFIED`, keep `metric_field` and `visual_field` separate, and use the reviewer line verbatim (`A05 §7:249-250,293-295`; `X07 §8`):
  > PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.
- Once the owner supplies a donor frame, COORD must update that line to "Donor frame supplied by owner; parity still UNVERIFIED pending demonstrated match" — **this template does not make that transition itself** (`X39 §4:176`). No "donor match / parity / confirmed" wording at any stage (`X39 §4:190-192`; `A05 §4:200-205`).

---

## 6. IF THE OWNER DECLINES — permanent UNVERIFIED

**[D]** If the owner will not or cannot personally run the donor and supply the §2 manifest + out-of-repo `.map`/PNG, then **no route is viable** (`X39 §0 item 6`, `§7 Q1`, `§8 line 5`):

- Donor parity is **permanently `UNVERIFIED`** — declared and accepted (`declared_unverified` tier 3, `X39 §0:37`; V15 §2). It is **not** a gate failure, and never "donor match".
- The honest owner-facing verdict is: **"gates green / internal consistency PASS / donor parity UNVERIFIED"**, provided no blocking QA item is missing (`X39 §8 line 5`; `A05 §9:357-358`; `spec §12.6`).
- This template then remains an **unfilled form**; no field is back-filled with an assumed value, and no synthetic donor frame is manufactured (`CHARTER.md:84`; `X39 §8 line 1`).

---

## 7. Five-line summary (for COORD)

1. **[D]** This is a **blank fill-in template** for X39 Route A — the only admissible donor A/B path — written by V92 as exactly one new repo file; no donor was executed/copied, no Godot job submitted, no capture, hash, ROI or metric invented.
2. **[O]** Prerequisites are pinned with citations: donor owner-run at `C:\Games\Cossacks 3`; size 320 enum 0 (`donewgame.inc:42-49`); Land/TerrainTypes 0 (`generator.cfg:2-66`); season int 0/2/3 (X30 §0); explicit `randkey0/1` u32 (`spec/02 §1`, D02); camera `camera.cfg` tilt −32°/focal 400/dolly 20–58/DOV 1200 (G31 §2a) and profile name; window 1280×720; port keys mirrored (A05 §2.1).
3. **[D]** The form records donor build, both seed keys, out-of-repo `.map` and PNG paths, camera values, ground-only ROI `(x0,y0,x1,y1)`, timestamp and SHA-256 of map+PNG (`Get-FileHash -Algorithm SHA256`), plus owner attestation; the port capture command is a placeholder with `<UNIQUE>` id for COORD to run via `godot_runner.py`, one job at a time, under G0-a…e admissibility (`V42 §4.10`; `A05 §4.1`).
4. **[O]** Comparison protocol is same scene/seed/camera/ROI at A/B-L1 (input-matched) or A/B-L2 (scene-matched); `terrain_ab_metric.py --crop-frac` gives direction hints only, `compare_shots.py --threshold 0.9999` is self-determinism only; parity stays `NONE`/`UNVERIFIED` until COORD rules a demonstrated match (`X39 §4`; `A05 §4.2`; `spec §12.6`).
5. **[O]** Privacy guard: never copy donor files into the repo, never redistribute, assistant/workers never execute the donor, hashes recorded as text only; if the owner declines, parity stays permanently `UNVERIFIED` with verdict "gates green / internal consistency PASS / donor parity UNVERIFIED" — never "donor match" (`CHARTER.md:28-30,66-70`; `X39 §0:37, §7 Q1, §8 line 5`).

---

*End of OWNER CAPTURE TEMPLATE. Blank form only — not filled, not executed, not a capture, not a gate result, not a parity claim. Exactly one new repo file written; no donor binary executed or copied; no Godot/runner job; no code, Godot, git or donor write. Donor parity remains UNVERIFIED.*
