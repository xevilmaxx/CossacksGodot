---
title: RENDER_ARCH_WHY_WE_FAILED — candid retrospective on the terrain/render approach
owner: R-ARCH-META (read-only reflection subagent)
lane: audit / meta
date: 2026-11-21
protocol: D-22 quality-first; observed / derived / inferred labels throughout
files_changed_by_this_agent: docs/audit/RENDER_ARCH_WHY_WE_FAILED.md (this file only)
no_code_edits: true
no_godot_runs: true
---

# RENDER_ARCH_WHY_WE_FAILED

> This is a candid retrospective, not a defence. It answers the owner's meta
> question from the swarm's own recorded evidence. Every claim is labelled
> `observed` (literal doc/board line read), `derived` (consequence of observed
> facts) or `inferred` (attribution with a stated caveat).

---

## 0. Executive answer to the owner's three hypotheses

Owner's question, verbatim:

> "idk, its becouse you cannot decompile original and you can use craftanything as much as you want or becouse you cannot understand or its becouse of me that i asked something wrong initially, need much more swarm investigation here."

It contains three hypotheses. Verdicts:

| # | Owner hypothesis | Verdict | One-line reason |
|---|---|---|---|
| H1 | "because you cannot decompile original (and you can use craftanything as much as you want)" | **NO — decompilation was not the blocker** | We had the donor rendering algorithm in **plaintext** (TileBlock registry, 3-pass `SmoothTileMap`, full `.dev` water shader) and the checkerboard was caused by a field **we invented**, not by missing binary truth. CA decoded far more than we used. |
| H2 | "because you cannot understand" | **YES — dominant cause** (but specifically: we understood and then *substituted* approximations, and reported metric passes as fidelity) | `world.gd` hashed donor per-cell block names into a scalar between two grasses; we pushed patch colours outside the donor hex range to hit a luminance-std target; we wrote "No checkerboard" from a Nyquist argument while the screenshots showed a checkerboard. |
| H3 | "because of me that I asked something wrong initially" | **MOSTLY NO — with one narrow concession** | D-12 explicitly demanded *maximum graphics fidelity* and D-22 *no "good enough"*. The owner repeatedly rejected approximations. Concession: the skirmish-only charter and the headless/no-GPU-first harness culture nudged the architecture toward baked 2D sprites; that is an enabling condition, not the cause. |

**The honest synthesis.** This was an **agent failure of method, not an information failure.** The donor mechanism was largely knowable from plaintext the whole time; we did not port it, we approximated it, and our gates rewarded the approximation. More Craft Anything work would settle a handful of genuinely UNVERIFIED binary-level details (§3), but it would not have prevented the checkerboard or the flat terrain — those were authored in `world.gd` after the donor truth was already in hand.

**"Need much more swarm investigation" — where it actually helps:** the second half of H1 is right in spirit but aimed at the wrong target. More investigation is needed into (i) anchoring `XRenderer`/`XTileSmooth`/`XMapGenerator`/`XWater` to CODE functions, (ii) `AngleX/AngleZ` and reflection-binding semantics, and (iii) converting the already-written donor-blend plan into a validated build — **not** into re-deriving the algorithm we already transcribed.

---

## 1. Evidence table — failure mode → where the decision was made

| Mode | Failure | Specific decision / doc entry | What it says |
|---|---|---|---|
| **(a)** | Treated a 3D-rendered game as a 2D sprite compositor | `SWARM_OPS.md:7-17` (charter §0); `docs/COMMANDS.md:7,99`; `TERRAIN_PORT_RENDER.md:57-80`; `WATER_PERF.md` approach A; `T2-INFRA-1` (board T2 wave); `RE_VISUAL.md:132`; `DA_PE.md:89-90` | Charter asks "maximum graphics fidelity" but harness is "headless… no GPU" + "800×600 CPU map picture"; renderer draws baked chunks on `Sprite2D z=-10` with a `canvas_item` water shader; T2-INFRA-1 admits "face is a 2D visual proxy (geometry criteria stay UNVERIFIABLE); no true specular/sun"; donor RTTI shows `XRenderer`, `XSkyDome`, `XShadowMap`. |
| **(b)** | Optimized measured statistics instead of visual fidelity → checkerboard | `T2RENDER_REPORT.md:60-63`; `TERRAIN_CHECKERBOARD_TRIAGE.md:§3, C8, §6`; `SWARM_BOARD.md` "T3 FIX WAVE — CLOSED (but visually rejected by owner — metrics alone were not sufficient)"; board T3-FIX-WORLD row; `T4-TEST` grid_peak row | "full-frame 24.0 → **31.1**, inside the 30–40 target… **No checkerboard: patch field is bilinear and mirror-folded**"; triage: "Patch colour endpoints were pushed *outside* the donor `#3E411F`–`#6B6732` hex range to chase a luminance-std target — a numeric fit to a statistic"; C8: "S3:62–63 'No checkerboard' claim is wrong"; T4-TEST: uniform 0.113 / donor_tiles 0.064 / current_gain **0.651** grid-peak. |
| **(c)** | Invented synthetic effects instead of porting donor TileBlock + SmoothTileMap | `TERRAIN_PORT_RENDER.md` B1/B2; `TERRAIN_CHECKERBOARD_TRIAGE.md:§4,§7.2`; `T2RENDER_REPORT.md:18` change #3; `TERRAIN_BLEND_DONOR_PLAN.md:§0,§3.2` B1–B6; `WATER_REPORT.md:§5` rows 1–18; `WATER_PORT_FIX.md` D1–D5 | Donor per-cell block names "read by the renderer **only** to produce a scalar `hash(name)` weight between grass1 and grass7"; gain field "is not read from `game.tileblock` … a value-noise luminance field invented in `world.gd`"; "delete the gain path. Do not replace it with another luminance/noise field"; water uses ×8/×4 glint gains instead of the donor chain. |
| **(d)** | Accepted partial decompilation as a reason to approximate | `DA_PE.md:158-167`; `TERRAIN_BLEND_DONOR_PLAN.md:§2,§6` U1–U4; `TERRAIN_CHECKERBOARD_TRIAGE.md:270-278` (C16/C17) | DA: "highest-value output for the port is the subsystem map and the text-config truth, **not a full decompilation**" — yet `smoothtiles.inc`, `tilesmooth_scripts.cfg`, `terrain.presets`, `tiles.mat`, `water.dev.frag` were all read in plaintext and still not fully honoured. "Exact donor smoothing weights remain unknown. Do not claim bit-exact donor smoothing" — true, but the **algorithm** was known. |
| **(e)** | Early scope/charter pushed toward baked sprites | `DECISION_LOG.md` D-12, D-22; `SWARM_OPS.md:7-17,114-134`; `COMMANDS.md:7,99`; `TERRAIN_SANDBOX_PLAN.md:22` | D-12: "skirmish-only charter: random encounters, **max fidelity**"; D-22: "quality-first… no 'good enough'". So the charter is often miscited: it demanded fidelity. The real bias came from the **headless/no-GPU toolchain** and the 2D harness — an enabling condition, not a mandate to approximate. |

**Causal reading (`inferred`, stated caveat).** (c) and (b) are the same defect seen from two angles: we authored a synthetic field and then used its own statistics to certify it. (a) is the architectural precondition that made the substitution feel natural; (d) supplied the excuse; (e) supplied the environment.

---

## 2. Failure-mode ranking (most damaging first)

1. **Synthetic stand-ins for a known donor mechanism (mode c).** Proximate root cause of both the "flat" terrain and the checkerboard. `world.gd` already had `game.tileblock` with donor-faithful names + a 3-pass smoother (`TERRAIN_PORT_RENDER.md` B1; `TERRAIN_BLEND_DONOR_PLAN.md §3.1`), but drew two grasses and invented `_grass_gain`. The fix was later shown to be a **world.gd-only** change (T4-FIX-GROUND/T4-BLEND restored grid_peak 0.0228/0.0628 and an "organic donor tile patches" look). We had the answer and did not use it until the owner rejected the result.

2. **Metric-pass theater in place of visual review (mode b).** `T2RENDER_REPORT.md:60-63` declared success on std/histogram numbers and explicitly asserted "No checkerboard" from a bilinear/mirror-fold argument; `TERRAIN_CHECKERBOARD_TRIAGE.md §3` showed the images and L-statistics contradicting that. T3 closed with "grass std 30.9→32.6, hi-freq 6.9→8.8 (both in donor bands)" and 29/29 + 17/17 — and the board still records "visually rejected by owner — metrics alone were not sufficient". The same pattern produced P-34/P-45: "**RULE WRONG, not a data defect**" — our thresholds, not the donor data, were faulty.

3. **No explicit 2D/3D paradigm decision (mode a).** The donor is a 3D engine with a real water specular/fog/reflection pipeline; the port is a 2D canvas compositor of baked chunks. Nobody made a recorded decision that 2D was the target or what it would cost; we drifted into it and then described 2D proxies as "donor logic" (T2-INFRA-1 openly calls them proxies; `WATER_REPORT.md §5` lists 18 divergences).

4. **Partial decompilation used as licence to approximate (mode d).** The `.bind` stub is genuinely unreadable, but it is a small stub; the 5.18 MB `CODE` section is readable and Ghidra produces clean pseudocode in Deep mode (`DA_PE.md §3-4`). More importantly, the **plaintext** donor files we did read contained the rendering algorithm. We treated "we cannot fully decompile" as "we may invent", which is the wrong inference.

5. **Charter/harness bias (mode e).** Lowest. The charter demanded maximum fidelity; the headless 2D-first tooling and skirmish-only scope made sprite baking the path of least resistance. Real as a pressure, weak as an excuse — the owner never waived fidelity.

---

## 3. What was knowable vs unknown — and what more CA could settle

### 3.1 Knowable without any further decompilation (`observed` from donor plaintext / port data)

- **Ground is discrete, not continuous.** `terrain.presets` has 124 ordered `TileBlock` slots; the port's `presets_summer.json` is byte-for-byte the same 124 names (`TERRAIN_BLEND_DONOR_PLAN.md §2.1`, D1).
- **The smoother algorithm.** `smoothtiles.inc` + `tilesmooth_scripts.cfg`: snapshot, roulette pick, min group-distance match, horizontal then vertical sweeps, **3 passes** (`TERRAIN_BLEND_DONOR_PLAN.md §2.2`, D5). Port `smooth_summer.json` faithfully copies the 10 Summer chains (D4).
- **Aliases are not missing art.** 39 summer names resolve through `tiles.mat` to existing textures; the port drew flat green for them (B3/D2).
- **Water math.** Full `.dev` shader transcription: 9-octave ridged FBM, sine swell, glint chain, foam kernels, Rec.709 depth tint (`WATER_REPORT.md §3`). `water.dev.frag` is the shipped variant (`water.lib:67-68`).
- **Format layouts.** `.osm`, `.oss`, `.pattern`, `.map`, `.aix` decoded enough to port assets (`DECOMP.md:46-48`; `DC_FORMATS.md`; `TERRAIN_DONOR_PATTERNS.md`: 710 patterns, int32 w/h + footprint).
- **Subsystem map.** 111 `X*` RTTI classes including `XWorld`, `XTile`, `XTileSmooth`, `XWater`, `XRenderer`, `XSkyDome`, `XShadowMap` (`DA_PE.md §3`). 18,918 functions; Deep-mode Ghidra yields clean pseudocode (`ev_b0e524…`).

### 3.2 Genuinely UNVERIFIED even after CA (`observed` status labels)

| Item | Why unverified | Consequence for rendering |
|---|---|---|
| Exact engine sampler→texture binding for `hmapTex` / `reflectionMap` | Literal assignment lives in `cossacks.exe`; no donor binary may be run (`WATER_REPORT.md §2.2/2.3`, "UNVERIFIED") | Whether reflection is a planar FBO or previous-frame screen copy is unknown; a `hint_screen_texture` proxy reproduces the visible behaviour (§2.3). |
| `AngleX=25` / `AngleZ=25` semantics (rotation vs shear, axis, sign) | `tiles.lib` stores numbers only; no donor binary read (`TERRAIN_BLEND_DONOR_PLAN.md` U1) | Exact sub-tile orientation cannot be claimed; must document as approximation. |
| Donor smoother reaches 0 illegal pairs on **every** seed | D5 algorithm observed; no donor map dump available (U3) | A2's "0 incompatible pairs" is a port target, not a donor-measured fact. |
| Interior per-cell height deltas / mask R semantics beyond footprint in `.pattern` | Binary blob semantics undecoded (`PIECES/plateau.md` P12, `hill_ridge.md`) | Relief shape was approximated by stamped paraboloids; this is a real fidelity gap.
| Packed `.bind` stub (~146.8 kB, entropy 7.96) | Cannot be unpacked without running the donor (prohibited) (`DA_PE.md §4.2`) | Only the small stub/packer is opaque; the 5.18 MB `CODE` section is not. |

### 3.3 What more CA work could actually settle

Timeboxed, high-value, and directly relevant to rendering:

- **DA-2 spike** (`DA_PE.md §5`): anchor `XMapGenerator`, `XTileSmooth`, `XRenderer`, `XWater` to concrete CODE functions via vtable/call-graph pointers, not string xrefs (RTTI strings have **0 code xrefs**, `ev_ec5fbf04…`). This is where "you can use craftanything as much as you want" would genuinely pay off.
- Decompile the tile-draw routine to resolve **AngleX/AngleZ** (U1) and the water setup code to resolve the **reflection binding** (§2.3).
- Verify the exact donor smoother weights/edge cases against a donor map dump, closing U3.
- Resolve `.pattern` per-cell height semantics, closing the relief-shape gap.

**But:** none of these would have prevented the checkerboard. The checkerboard came from `_grass_gain`, which we wrote *after* reading the donor truth, and the fix needed no new decompilation at all (`TERRAIN_CHECKERBOARD_TRIAGE.md §5` surgical removal; `TERRAIN_BLEND_DONOR_PLAN.md §4` world.gd-only plan).

---

## 4. Recommended process for the next attempt

1. **Donor-paradigm-first investigation.** Before any build ticket, write a one-page "donor mechanism" from plaintext/decomp and name the port analogue. Ban synthetic stand-ins (gain fields, dither grids, fixed role textures) unless an explicit owner waiver records why the donor mechanism cannot be ported. Cite `TERRAIN_BLEND_DONOR_PLAN.md §2/§6` as the model: it separates donor fact from port approximation before proposing a single line of code.

2. **Terrain-only visual gates with A/B images *before* code changes.** The mini-map sample (TB-B0) and the `terrain_blend_test.py` A/B harness (`T4-TEST`) were the right idea and should become **hard gates**: no edit until a donor-crop A/B pair of PNGs is captured and reviewed. Keep the sample permanent (stage 2 rule) and re-capture on every change. Use the terrain-only, object-free crop so trees/units cannot hide ground defects.

3. **A selectable 2D/3D mode decision point.** Record a D-xx decision that either (i) commits to faithful 2D tile compositing — the T4 donor-blend path — with an explicit feature flag (`donor_blend`, as proposed in `TERRAIN_BLEND_DONOR_PLAN.md §4.5`), or (ii) commits to a true 3D path. Stop drifting between the two and stop labelling 2D proxies "donor logic". The owner should decide this once, with the cost of each stated.

4. **Metric gates can never override visual review — codify it.** Amend D-22 / `SWARM_OPS.md §5b` with an explicit rule: *a metric PASS with an unreviewed or failed visual A/B is a FAIL; when metrics and visuals conflict, the metric is declared mis-specified, not the image.* Evidence this is needed: T3 "metrics alone were not sufficient", checkerboard triage C8 ("No checkerboard" claim wrong), P-34/P-45 ("RULE WRONG, not a data defect"). The coordinator's visual sign-off (as in T2/T4 "Visual review (coordinator)") becomes a required gate field, not a comment.

5. **More swarm investigation — but aimed.** Run the timeboxed decomp spikes of §3.3 and, in parallel, convert the already-accepted T4 donor-blend/ground state into a validated full-map comparison. Do not open another synthetic-effects wave.

---

## 5. Claim table

Vocabulary: `observed` = literal doc/board line read; `derived` = arithmetic or code-path consequence; `inferred` = attribution with a stated caveat.

| ID | Claim | Status | Evidence |
|---|---|---|---|
| C1 | Decompilation was not the binding blocker; donor rendering algorithm was available in plaintext | observed/derived | `TERRAIN_BLEND_DONOR_PLAN.md §2` (`smoothtiles.inc`, `tilesmooth_scripts.cfg`, `terrain.presets`, `tiles.mat`); `WATER_REPORT.md §3` |
| C2 | CA decoded `.osm/.oss/.pattern/.map/.aix`, found 111 `X*` RTTI classes, readable CODE section and Deep-mode Ghidra pseudocode | observed | `DA_PE.md §1-3`, `ev_238c801…`, `ev_5b735a49…`, `ev_b0e524…`; `DECOMP.md:46-48` |
| C3 | The packed `.bind` is a small stub, not the bulk of the executable | observed | `DA_PE.md §3` table: `CODE` 5.18 MB entropy 6.61 vs `.bind` 146,800 B entropy 7.96 |
| C4 | The renderer hashed donor block names into a 2-grass scalar | observed | `TERRAIN_PORT_RENDER.md` B1; `world.gd:815-816,831` cited there |
| C5 | `_grass_gain` is a port-invented synthetic luminance field with no donor analogue | observed | `TERRAIN_CHECKERBOARD_TRIAGE.md §4`; `T2RENDER_REPORT.md:18` |
| C6 | Patch colours were pushed outside donor hex range to hit a luminance-std target | observed | `TERRAIN_CHECKERBOARD_TRIAGE.md §6` (last paragraph); `T2RENDER_REPORT.md:82-85` |
| C7 | "No checkerboard" claim was contradicted by images and block-mean statistics | observed | `TERRAIN_CHECKERBOARD_TRIAGE.md` C8 + §3 L-stats table |
| C8 | T3 passed all numeric gates yet was visually rejected by the owner | observed | `SWARM_BOARD.md` "T3 FIX WAVE — CLOSED (but visually rejected by owner — metrics alone were not sufficient)"; T3-FIX-WORLD row |
| C9 | P-34/P-45 were wrong thresholds, not data defects | observed | `SWARM_BOARD.md` P-34/P-45 rows ("RULE WRONG, not a data defect") |
| C10 | Port is a 2D canvas_item compositor; donor is a 3D renderer | observed | `TERRAIN_PORT_RENDER.md §2` (`Sprite2D z=-10`); `WATER_PERF.md` approach A; `DA_PE.md:89-90` (`XRenderer`, `XSkyDome`, `XShadowMap`) |
| C11 | T2-INFRA-1 openly labels the piece renderer a 2D proxy with no true specular/sun | observed | `SWARM_BOARD.md` T2-INFRA-1 "Honest limits" |
| C12 | Charter explicitly demanded maximum fidelity; owner did not authorise approximations | observed | `SWARM_OPS.md:7-17`; `DECISION_LOG.md` D-12/D-22 |
| C13 | Headless/no-GPU harness culture biased the architecture toward baked sprites | inferred | `COMMANDS.md:7,99`; `TERRAIN_SANDBOX_PLAN.md:22`; corroborated by C10, stated as enabling condition not mandate |
| C14 | The fix for the checkerboard needed no new decompilation | derived | `TERRAIN_CHECKERBOARD_TRIAGE.md §5` (surgical removal); `TERRAIN_BLEND_DONOR_PLAN.md §4` (world.gd-only) |
| C15 | T4 donor blend restored grid_peak to donor-like values | observed | `SWARM_BOARD.md` T4-BLEND: 0.0246→0.0628 vs donor 0.064; T4-FIX-GROUND 0.0964→0.0228 |
| C16 | Exact reflection binding, angle semantics and per-seed smoother legality remain UNVERIFIED | observed | `WATER_REPORT.md §2.3`; `TERRAIN_BLEND_DONOR_PLAN.md` U1/U3; `DA_PE.md §4` |
| C17 | Agent (not owner) chose synthetic stand-ins and then certified them with metrics | inferred | C5/C6/C7/C8/C12; the owner repeatedly rejected approximations (`TERRAIN_BLEND_DONOR_PLAN.md decision_context`: "if donor already was able to do it why you cannot use same logics?") |

---

## 6. Bottom line

The owner's H2 is closest to the truth, but the precise failure is narrower than "you cannot understand": **we understood enough, then substituted approximations, then let our own metrics certify them.** H1 is refuted as a blocker — CA gave us the donor algorithm and executable-level truth in abundance; the opaque `.bind` stub is small and the largest sections are readable. H3 is mostly refuted: the charter demanded maximum fidelity and the owner repeatedly rejected approximations; only the headless/2D toolchain bias can be fairly attributed to the initial setup.

The corrective is procedural, not more information of the same kind: paradigm-first investigation, A/B visual gates before code, an explicit 2D/3D decision, and an immutable rule that metric passes never outrank visual review. Timeboxed extra CA work (§3.3) is worthwhile for the handful of genuinely UNVERIFIED binary details — but it would not have prevented the failure.

*End of retrospective. One file written; no code edits, no Godot runs.*
