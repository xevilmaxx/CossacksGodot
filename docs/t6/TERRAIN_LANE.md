# T6-TERRAIN LANE — terrain graphics fidelity, piece by piece

Parent: **T6-TERRAIN** (lane session `ses_df83a3717ffedjlk7Nu0JnxU16`, model
`opencode/hy4-flash-free#high`). Created 2026-11-23. Source of truth: `SWARM_OPS.md` §7,
`docs/T6_WAVE_PLAN.md` §1 + LANE TERRAIN, `app/tools/AGENT_PROTOCOL.md`.

**Rule:** one micro-worker per piece. Each child measures donor truth FIRST, implements
ONE headless Python/Pillow mini-baker, renders its piece PNG + side-by-side donor compare,
measures every acceptance criterion, labels claims `observed`/`derived`/`inferred`, and
writes `docs/t6/reports/<ID>.md` BEFORE reporting done. **Zero Godot jobs.** Metrics never
override visual review. `app/tools/terrain_piece_render.py`, `piece_specs/*.json`,
`world.gd`, `game.gd` are READ-ONLY for every child. Never edit another lane's files.

Donor truth: `C:\Games\Cossacks 3\data\` (private use, never redistribute). Reference images:
`C:\Users\Maxym.Oboyshev\Downloads\c3\` (primary `cossacks-3-v1-498085.jpg`).

## Ticket table

| Ticket | Piece / micro-task | Child sessionID | Owned files | State | Evidence / PASS-FAIL |
|---|---|---|---|---|---|
| T6-T01 | grass_mottled mini-baker | `ses_df833c636ffeJrSERnmM9Bhzlg` | `app/tools/pieces/t6_grass_mottled.py`, `docs/audit/PIECES/grass_mottled.md` (append), `app/shots/pieces/t6_grass_mottled*.png`, `docs/t6/reports/T6-T01.md` | **PASS** | `docs/t6/reports/T6-T01.md`: 11 PASS / 0 FAIL; reworked octaves + fine grain (hf 8.06→10.58 vs donor relief 11.18; grid_peak 0.147→0.083; histogram L1 ≤25). Parent personally re-opened compare: donor crops contain grass (no minimap/UI), edges now ragged, no coarse blobs. Child's spec-based objection to parent's earlier "clean grass" critique accepted — #8 clean grass is the NEGATIVE CONTROL; mottled contract requires std 30–40 and broad tonal regions, so no C1/C3 spec revision. Counts. Residual ~1.8% yellow sunlit-tip pixels → combo/owner review. |
| T6-T02 | shore_sand mini-baker | `ses_df833c540ffezakkq0xPc3a9ov` | `app/tools/pieces/t6_shore_sand.py`, `docs/audit/PIECES/shore_sand.md` (append), `app/shots/pieces/t6_shore_sand*.png`, `docs/t6/reports/T6-T02.md` | **REMEDIED — awaiting coordinator final clear** | Parent re-opened current PNG: both findings fixed. Concentric arcs gone — water body is READ-ONLY T6-W02 `t6_water_shore.png` placeholder, M8 NOT SCORED (W02 scope). Contaminated crop replaced by clean #12 sub-crop `(345,190,420,250)`, visually free of UI/minimap/units and containing the sand/wash feature. Hidden wash error exposed and fixed (#AEAF9E→#BABEB1 vs donor #BCC6BD, Δ12). All scored-feature gates PASS; REVOKED/REVISED report section appended. Final clear requested; still excluded until ruled. |
| T6-T03 | shore_rock mini-baker | `ses_df813864affehficNCkTs562wR` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_shore_rock.py`, `docs/audit/PIECES/shore_rock.md` (append), `app/shots/pieces/t6_shore_rock*.png`, `docs/t6/reports/T6-T03.md` | **PASS** | `docs/t6/reports/T6-T03.md`: 12 PASS / 0 FAIL; rock8 fill + rock1 flutes, flute anisotropy 11.06 (≥3), lit/shadow 1.973 (≥1.8), rim median 2 px. Parent personally re-opened compare + facecrop: donor crop `(840,360,1100,480)` contains real rock face; no plank fence / black contour / zigzag rim / flat light. Compare SHA `e70ba6388815…`. Counts. Open: `rock_stones1` absent (dimmed `rock_sea1` stand-in); final on-screen read needs camera-fixed capture at combo/T90. |
| T6-T04 | shore_water_transition mini-baker | `ses_df833c488ffe1qtCtj6JciZr7H` | `app/tools/pieces/t6_shore_water_transition.py`, `docs/audit/PIECES/shore_water_transition.md` (append), `app/shots/pieces/t6_shore_water_transition*.png`, `docs/t6/reports/T6-T04.md` | **QUALIFIED — C7 probe route escalated** | Parent re-opened new compare + dark-probe PNGs: dark right-edge band and concentric arcs **gone**; organic edge + soft contact shadow retained; donor #12 panel valid (no UI/minimap). C7 depth colour now demonstrated only on a separate labelled `t6_shore_water_transition_dark_probe.png` (#A8B1AB vs #333C3F) because donor #12 has no dark water. Child withdrew its arcs claim and appended a QUALIFIED/NOT-full-PASS section. Parent **escalated the C7 probe route to the coordinator** rather than self-accepting an acceptance-scope change. Compare SHA `8437388427510cbb…`; stays excluded from count. |
| T6-T05 | ravine_face mini-baker | `ses_df833c30bffe2H7m4xrptkYCF1` | `app/tools/pieces/t6_ravine_face.py`, `docs/audit/PIECES/ravine_face.md` (append), `app/shots/pieces/t6_ravine_face*.png`, `docs/t6/reports/T6-T05.md` | **REVOKED by coordinator** | Parent re-opened current PNG: all four named defects unchanged (uniform striations/wooden fence, hard black contour, perfect zigzag, flat lighting). Report claimed fixes while render is pixel-similar → pipeline bug or false claim. Directed: prove code actually executes (module version/hash in PNG header or manifest + before/after pixel diff), append REVOKED/REVISED section, then genuinely fix the four defects. |
| T6-T06 | hill_ridge mini-baker | `ses_df810e13fffeVs9yDw2Krnw0CN` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_hill_ridge.py`, `docs/audit/PIECES/hill_ridge.md` (append), `app/shots/pieces/t6_hill_ridge*.png`, `docs/t6/reports/T6-T06.md` | RUNNING | S01 heightfield context (256/320/480/640 donor grids vs port 160²) included in prompt. |
| T6-T07 | plateau mini-baker | `ses_df8106a70ffe2ipmykCD72jj4u` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_plateau.py`, `docs/audit/PIECES/plateau.md` (append), `app/shots/pieces/t6_plateau*.png`, `docs/t6/reports/T6-T07.md` | **CONDITIONAL / HOLD — P-45 adjudication with coordinator** | Child revoked its own "PASS (cautious)" and appended a formal P-45 wrong-threshold request with donor proof: #8 clean plateau crop (375,20,440,85) measures L std 8.057, hf 4.21, only **2 of 8 bins ≥3%**; relief-containing crops show 4 bins at std 20.9–26.2 (corroborated by TERRAIN_REFERENCE_IMAGES §3.3). 4 contiguous bins forces ≥96-level span ⇒ std ≳17, conflicting with the same criterion's std ≤10; no genuine render fix exists. Parent relayed the request to the coordinator. No threshold weakened; renderer/spec/PNG unchanged. 2 geometry UNVERIFIABLEs → T90 dump verifier. Excluded from count until ruled. |
| T6-T08 | forest_conifer mini-baker | `ses_df80fa136ffeiFHmfu0gdaGWQU` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_forest_conifer.py`, `docs/audit/PIECES/forest_conifer.md` (append), `app/shots/pieces/t6_forest_conifer*.png`, `docs/t6/reports/T6-T08.md` | **HOLD — invalid crops + unmet global gate** | Child's 8/8 ranked PASS and genuine density/shadow fixes noted, but parent re-opened BOTH compare sheets: dense #11 panel has a minimap/UI panel + unit formations; primary #8 panel has troop formations — invalid donor crops (T02 revocation class). Supporting global HSV gate not met (sat 0.551 >0.55, val 0.207 <0.25). Directed: clean/composited donor panels, re-run A/B, append REVOKED/REVISED section, and either meet the gate or supply formal P-45 donor-measurement proof for adjudication through parent. Excluded from count. |
| T6-T09 | forest_broadleaf mini-baker | `ses_df833c271ffeXEY64IThJAwKpL` | `app/tools/pieces/t6_forest_broadleaf.py`, `docs/audit/PIECES/forest_broadleaf.md` (append), `app/shots/pieces/t6_forest_broadleaf*.png`, `docs/t6/reports/T6-T09.md` | **HOLD — PARTIAL + contaminated crop** | Report: 7 PASS, **1 PARTIAL** (conifer wide_frac 0.347 at rendered-component scale vs ≤0.30; source sprites 0.194–0.251 PASS), global gate PASS. Parent re-opened compare: donor panel [180,200,340,340] contains cavalry/unit formations → contamination. Directed: fix rendered conifer silhouette or request P-45 adjudication with donor proof through parent; replace donor panel with a clean broadleaf crop (no units/minimap/UI); append REVOKED/REVISED section. Excluded until ruled. |
| T6-T10 | bushes_understory mini-baker | `ses_df8005355ffeJKNIwdnY66J5D9` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_bushes_understory.py`, `docs/audit/PIECES/bushes_understory.md` (append), `app/shots/pieces/t6_bushes_understory*.png`, `docs/t6/reports/T6-T10.md` | RUNNING | Prompt includes the binding valid-donor-crop rule (T02/T12/T15 revocation class) and the hard-outline/uniform-pattern/contact-shadow defect list. |
| T6-T11 | stones_rocks mini-baker | `ses_df7fb6afbffe9e92R2ODANG9SM` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_stones_rocks.py`, `docs/audit/PIECES/stones_rocks.md` (append), `app/shots/pieces/t6_stones_rocks*.png`, `docs/t6/reports/T6-T11.md` | RUNNING | Binding valid-donor-crop rule + defect list in prompt. |
| T6-T12 | mines_display mini-baker | `ses_df833c1b3ffeHvVTgIIEWWLBH7` | `app/tools/pieces/t6_mines_display.py`, `docs/audit/PIECES/mines_display.md` (append), `app/shots/pieces/t6_mines_display*.png`, `docs/t6/reports/T6-T12.md` | **REVOKED — arbitration with coordinator** | Corrections delivered: invalid mine-less crop replaced by labelled donor `mine_gold` sprite art (no catalogued reference contains a mine); mirror-tiling gone; real `ground1` clearing on `grass1` + directional contact shadow; REPORT REVOKED section appended. Parent re-opened sheet: valid sprite-art target, legible mine, but child reports **visual FAIL** (flat 2D proxy, no engine lighting) and **A6 FAIL** (3.91 tiles — component is whole clearing). Parent adds residual: clearing has a hard near-rectangular edge. Child's A6 prop-footprint vs worked-apron metric-definition arbitration relayed to coordinator. Excluded from count. |
| T6-T13 | field_crops mini-baker | `ses_df7fb6686ffer9tpLTEmfm7ESQ` (`opencode-go/hy4-flash-free`) | `app/tools/pieces/t6_field_crops.py`, `docs/audit/PIECES/field_crops.md` (append), `app/shots/pieces/t6_field_crops*.png`, `docs/t6/reports/T6-T13.md` | RUNNING | Binding valid-donor-crop rule + defect list in prompt. |
| T6-T14 | winter_variant mini-baker | `ses_df833c110ffeX5uetS5aStk3xC` | `app/tools/pieces/t6_winter_variant.py`, `docs/audit/PIECES/winter_variant.md` (append), `app/shots/pieces/t6_winter_variant*.png`, `docs/t6/reports/T6-T14.md` | COMPLETE / CONDITIONAL | `docs/t6/reports/T6-T14.md`: 27/27 winter blocks wired, 10 numeric/gate PASS / 0 FAIL; S03 applied as verbatim `WINTER_SMOOTH_CHAINS` (141 entries, prob=0 preserved, terminators excluded) + `chain_audit()` — data-only, hero hash unchanged. Child withdrew earlier PASS: visual CONDITIONAL, residual schematic conifers, owner review required. NOT counted. T90 chain-wiring hand-off recorded. |
| T6-T15 | desert_variant mini-baker | `ses_df833c06cffeyppyVyvvi6YE4z` | `app/tools/pieces/t6_desert_variant.py`, `docs/audit/PIECES/desert_variant.md` (append), `app/shots/pieces/t6_desert_variant*.png`, `docs/t6/reports/T6-T15.md` | **FULL PASS (D-32, coordinator final clear)** | C5 adjudicated/cleared by QA T6-Q04 (independent 7.03@512² vs 9.21@200² scale-artefact reproduction, donor 8.42 / render 8.66 / dark 10.97% / SHA match — P-45 class: wrong method, not wrong data). Valid visual A/B: donor panel = labelled 2×2 ground-truth contact sheet of `desert6/2/3/4` centre crops, no UI/minimap/degenerate strip; port shows clustered irregular cracked patches + dry boulder with contact shadow, no lattice. Compare SHA `9213f858d697…`. **NON-BLOCKING RESIDUAL → T90 review:** port patches softer/stained vs donor `desert2/3` sharper polygonal plates; `desert6` hairline cracks finer than port's. Named improvement item, not a silent gap. Engine 250 ms bake sub-item UNVERIFIED → T90 gates, non-blocking. **Counts toward ≥12/15.** |
| T6-T90 | INTEGRATION (gated, coordinator-granted, ONE builder owns world.gd) | — | shared engine files | NOT OPEN | opens only after ≥12/15 pieces PASS + owner visual review |

## Integration readiness

**3 / 15 full PASS** under the coordinator's binding counting rule: only
**UNCONDITIONAL** piece PASS (all criteria + clean visual A/B against a VALID
feature-containing donor crop) counts toward the ≥12/15 T90 grant condition.

- **T15 desert_variant — FULL PASS (D-32, coordinator final clear)**, first piece
  through the complete loop. Counts. Residual transfer to T90 listed in its row.
- **T03 shore_rock — PASS (12 P / 0 F)**, parent intake verified 2026-11-23:
  donor crop `(840,360,1100,480)` genuinely contains rock face; no plank fence,
  black contour, zigzag rim or flat lighting in the current PNG. Counts.
- **T01 grass_mottled — PASS (11 P / 0 F)**, parent intake verified 2026-11-23:
  valid grass donor crops, ragged fine grain, no coarse blobs; mottled-spec
  tonal regions accepted as intrinsic (clean-grass crop is the negative control).
  Counts.
- T02, T12: **REVOKED** after independent visual review of CURRENT compare PNGs —
  T02 contaminated donor crop, T12 mine-less crop; both awaiting child revisions.
- **T05: REVOKED → rebuilt R3 winding gully**, parent re-verified all four defects
  fixed, but final clear requested from the coordinator (no self-promotion);
  excluded until ruled.
- T04: **QUALIFIED ONLY** — residuals visually resolved, but C7 is demonstrated on
  a separate labelled probe; probe route escalated to the coordinator. Not counted.
- T07: **CONDITIONAL/HOLD** — P-45 adjudication with coordinator (histogram-bin
  threshold conflicts with donor flat plateau); excluded until ruled.
- T14 CONDITIONAL only; T08 and T09 HOLD (see supervision log); T06, T10, T11,
  T13 running on `opencode-go/hy4-flash-free`. All 15 tickets now spawned.
- INTEGRATION REQUEST will be written here only when ≥12/15 UNCONDITIONAL PASS.
  Parent never edits `world.gd`; integration is a single coordinator-granted
  builder (T6-T90).

## Supervision log

- 2026-11-23: lane doc created; first batch (highest-impact FAIL pieces) spawned:
  T01, T02, T04, T05, T09, T12, T14, T15 — all 8 accepted, `busy`, located in this
  project root. Each child was created as a true OpenCode subagent session
  (`parentID` = this lane session, `agent: general`, model
  `opencode/hy4-flash-free`, `subagent: allow` so each child may spawn its own
  tiny helpers). The named `subagent` tool is not exposed at this depth in the
  harness, so the equivalent documented session API was used; child completion
  reports arrive in this lane session's inbox.
- 2026-11-23: remaining 7 (T03, T06, T07, T08, T10, T11, T13) spawn as soon as
  first-batch children report / free slots. Escalation rule: a child that fails
  twice or is silent >20 min with no output is re-spawned on
  `opencode-go/muse-spark-1.3-contributor#high` with its failed report attached.
- Environment check: donor `data/` tree present; Python 3.14.3 / Pillow 12.1.1 /
  NumPy 2.4.3 available; `worker_health.py` shows this lane ALIVE, no terrain
  jobs stuck. Zero Godot jobs needed for this lane.
- **COORDINATOR DIRECTIVE ACKNOWLEDGED (2026-11-23):** launch milestone accepted;
  API `parentID` spawning approved and written into `SWARM_OPS.md` §7.2.
  - Quota risk: `opencode/hy4-flash-free` is quota-blocked in sibling lanes.
    All 8 first-batch children were audited just now: all `busy`, still in their
    read/spec phase, **no quota/429/model errors observed** in any message log.
    They have been sent a queued addendum: on any quota error, stop and report the
    exact error; parent then re-spawns that micro-task on
    `opencode-go/hy4-flash-free` with identical ticket + owned files.
  - **Model change:** remaining 7 tickets (T03, T06, T07, T08, T10, T11, T13)
    and all future helpers use `opencode-go/hy4-flash-free` (verified active,
    zero-cost). Spawn them as first-batch slots free (≤8 direct children).
  - Escalation after 2 failures: `opencode-go/muse-spark-1.3-contributor#high`.
  - Host facts pushed to every child: `python` (3.14.3), NEVER `python3`;
    Blender exists at `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`
    but this lane needs none; headless Python/Pillow only, zero Godot jobs.
  - Piece PASS = donor-band measurements **AND** visual A/B judgement of the
    compare PNG vs the donor crop. Metrics alone never pass a piece. `world.gd`
    stays untouched until T6-T90 integration is granted.
- Parent output spot-check (read as images, not trusted from filenames): all 8
  first-batch children now have staged piece modules + compare PNGs. No
  quota/429 error in any child log. Queued to all children: `python` not
  `python3`, helper model `opencode-go/hy4-flash-free`, stop-and-report on quota
  errors.
- **COORDINATOR VISUAL SPOT-CHECK relayed per piece (2026-11-23)** — defect
  guidance, NOT a verdict override. Each child keeps its own honest PASS/FAIL.
  A piece showing hard outlines, uniform procedural patterns or missing contact
  shadows CANNOT pass visual A/B regardless of metrics; the donor is an eroded
  3D landscape and a 2D proxy must read as organic rock/ground, not diagram art.
  Parent read all 8 staged compare sheets and queued these piece-specific notes:
  - **T05 ravine_face:** four objective defects — uniform vertical striations
    read as WOODEN PLANK FENCE (donor flutes irregular in spacing/width/depth
    with horizontal stratification modulation; keep rock8 fill + rock1 flutes
    but break uniformity); hard black contour (donor rim blends into grass with
    a soft shadowed collar); perfect zigzag centerline (donor edges organically
    irregular); flat lighting (donor has lit-top/shadowed-bottom ramp + ambient
    occlusion at grass contact).
  - **T01 grass_mottled:** large blurry CAMOUFLAGE BLOBS ~40–80 px vs donor fine
    2–5 px low-amplitude grain (std ~8.6, hi-freq ~2.96).
  - **T02 shore_sand:** clean continuous pale ribbon + thin dark contour vs
    mottled sand/noisy wash; check hard outlines and missing contact shadow.
  - **T04 shore_water_transition:** perfectly straight vertical bands and
    regular moiré ripples vs donor organic wave arcs/mottled wash.
  - **T09 forest_broadleaf:** top-down mini-map of tiny conifer icons + white
    rock lines vs donor close-up large muted olive-lime broadleaf crowns with
    soft contact shadows.
  - **T12 mines_display:** flat uniform dirt, tiny mine sprite, soft blob, no
    real contact shadow; donor crop is a documented proxy — do not claim an
    evidenced donor mine match that does not exist.
  - **T14 winter_variant:** stark black ICONIC conifers on near-pure-white
    speckle vs donor soft low-saturation snow with natural texture.
  - **T15 desert_variant:** repeated IDENTICAL stamp-like rectangular blotches,
    isolated hard-edged rock, olive/khaki vs donor warm sandy natural grade.
- **QA ESCALATION ACKNOWLEDGED (2026-11-23):** coordinator ruled T6-T15 C5 a
  genuine FAIL (cracked sub-band grain ~7.1 vs 8–9), not a parse error. Queued to
  the T15 child: keep iterating to a real C5 pass (its own suggested route:
  polygonal/voronoi crack mask matching donor `desert2/3` facets, hi-freq 8–9
  with dark coverage ≤25% to preserve C3); re-render, re-measure C1–C8, update
  the report with new numbers and a fresh honest visual judgement. A wrong-threshold
  claim (P-45 precedent) must be proven with fresh donor measurements (donor
  desert2/3 hi-freq, sampling method, crop coordinates, why 8–9 is unattainable
  at ≤25% coverage) and adjudicated through this parent — no self-pass, no
  silent threshold weakening. T15 stays RED and excluded from the integration
  count while red.
- **RESEARCH HAND-OFF RELAYED (2026-11-23):** read `docs/research/T6_S03_smooth_chains.md`
  and queued it to the T14 child as authoritative input: donor Winter chains
  C11–C20 (`tilesmooth_scripts.cfg:934–1810`) are exact `_winter`-suffix mirrors
  of the 10 Summer chains the port copies (141 entries, 0 Summer mismatches);
  transcribe from the cfg/doc, never invent probabilities; `Prob=0` names stay 0;
  the two empty terminators carry no data. Port has no `smooth_winter.json` and
  uses the Summer table via `WINTER_ART` — behavioural equivalence only
  `inferred`, donor runtime selection `UNVERIFIED`. T14 still owns only its piece
  module/doc/shots; chain wiring into `game.gd` stays a gated T90 item. S01
  heightfield grids (256/320/480/640 by donor map size; port only 160²) will go
  into the T06/T07 spawn prompts.
- **Report intake (2026-11-23):** T02 13 P/0 F (visual PASS caveated), T04 12 P/0 F/1 U
  (visual QUALIFIED PASS after fixing straight bands + moire, final hash
  `abb20ef4…`), T05 6 P/0 F/2 PNG-unverifiable (donor-plausible single face),
  T12 7 P/0 F (visual PASS as render proxy, donor equality UNVERIFIED), T14 10 P/0 F
  but visual CONDITIONAL (child withdrew earlier PASS), T15 still C5 FAIL + visual
  FAIL and iterating. T01/T09 reports pending. Counted conservatively: 4
  piece-scope PASS, 1 conditional, 1 red.
- **T03 spawned (2026-11-23):** first ticket on the coordinator-mandated
  `opencode-go/hy4-flash-free` model, session `ses_df813864affehficNCkTs562wR`,
  filling the slot freed by T04 completion. Prompt includes the T05-derived
  visual defect list (no wood-grain flutes / hard contour / geometric centerline /
  flat lighting) and all host facts.
- **T06/T07/T08 spawned (2026-11-23)** on `opencode-go/hy4-flash-free` as T14,
  T15 and T12 completed: `ses_df810e13fffeVs9yDw2Krnw0CN` (hill_ridge),
  `ses_df8106a70ffe2ipmykCD72jj4u` (plateau), `ses_df80fa136ffeiFHmfu0gdaGWQU`
  (forest_conifer). T06/T07 prompts carry the S01 heightfield-grid context
  (donor 256/320/480/640 vs port 160², generator/game.gd off-limits). Remaining
  queued: T10, T11, T13.
- **T12 self-downgrade (2026-11-23):** after the coordinator's defect guidance
  the T12 child added a directional cast shadow and brighter ore, re-read its
  PNGs, and **withdrew its earlier 7 PASS** — final metrics 6 PASS / 1 FAIL
  (A6 scale), visual A/B FAIL, piece FAIL. Recorded as RED; the earlier
  piece-scope PASS count is corrected from 4 to 3. This is the protocol working
  as intended: honest visual review over metrics.
- **T15 C5 re-review requested (2026-11-23):** child fixed C5 in report v4 by
  correcting the measurement scale (v3 7.12 was 512² vs the donor 200²
  convention) and tuning A8 opacity 0.85→0.80: render cracked interior 8.66 vs
  donor 8.42, dark coverage 10.97% ≤25%, sweep recorded, no threshold weakened,
  no adjudication requested; 0 FAIL, stamp lattice gone. Parent verified the
  report and **queued a QA re-review request to the coordinator** (`delivery:
  queue`, parent session). T15 stays excluded from the integration count until
  QA rules — parent does not self-clear a QA RED.
- **T14 completed (2026-11-23):** S03 applied as verbatim `WINTER_SMOOTH_CHAINS`
  (141 entries, prob=0 preserved, terminators excluded), `chain_audit()` runtime
  guard, T90 hand-off recorded; visual unchanged and still CONDITIONAL (residual
  schematic conifers), so not counted.
- **BINDING COORDINATOR QUALITY INTERVENTION (2026-11-23) — PASS claims revoked.**
  Independent visual review of the CURRENT compare sheets (mtimes 11:18–11:24,
  regenerated AFTER defect guidance, so not stale) revoked T05, T02 and T12 and
  downgraded T04 to QUALIFIED. Counting rule: only UNCONDITIONAL piece PASS (all
  criteria + clean visual A/B against a VALID feature-containing donor crop)
  counts toward ≥12/15 T90. **Current count: 0/15 full PASS.**
- **Parent intake verification performed personally** (SWARM_OPS §5b-QUALITY rule
  2 — report text is never intake evidence): I re-opened all four CURRENT compare
  PNGs with the image-read tool and confirmed, with my own eyes:
  - T05: uniform vertical striations still read as a wooden-plank fence; hard
    black contour; perfect zigzag centerline; flat lighting. All four named
    defects unchanged. Donor crop does contain rock faces, so the crop is not
    the problem — the render is.
  - T02: donor right panel visibly contains a minimap with red/green markers,
    UI text and units — measurements against it are invalid. Port water body
    still shows concentric rings (W02/T6-WATER scope, not T02's).
  - T12: donor crop (880,130,1180,300) shows towers, trees, ravine and troops —
    **no mine**. Port ground shows kaleidoscope mirror-tiling; the mine apron is
    a soft dark smudge. Both are visual FAILs.
  - T04: genuine improvement but a residual dark right-edge band and faint arc
    remnants remain — QUALIFIED only.
- **Per-piece relays queued (2026-11-23):** T05 — prove the updated code actually
  executes (module version/hash in PNG header or manifest + before/after pixel
  diff), investigate pipeline bug vs false claim, then genuinely fix all four
  defects; T02 — composite W02 output or a flat donor-matched shallow placeholder,
  score only sand/wash/rim, pick a clean feature-containing shore crop, redo
  anchors/measurements; T12 — find a mine-containing donor crop or compare to
  donor mine sprite art directly, fix mirror-tiling and apron smudge; T04 —
  resolve dark right-edge band + arc remnants. T02/T05/T12 must **append a
  REVOKED/REVISED section** to their reports (T04 a QUALIFIED/REVISED section)
  so the QA registry stops parsing stale PASS verdicts.
- **NEW BINDING PROCESS RULE for this lane:** on EVERY report intake the parent
  personally opens the CURRENT compare PNG with the read tool, checks the named
  defect list, and verifies the donor crop actually contains the feature under
  test. Report text alone is never intake evidence. No PASS is restored until
  the parent personally re-verifies the new PNG.
- **COORDINATOR RULING on T15 re-review (2026-11-23):** RED stays. Two conditions:
  (1) QA independently re-measures and confirms the v4 C5 method-artefact numbers
  (donor 8.42, render 8.66, opacity sweep, dark coverage 10.97%) — PENDING;
  (2) child replaces the DEGENERATE donor compare panel — crop (5,5,470,38) is a
  33-px-tall strip stretched ~10x into a wooden-siding smear, invalid for visual
  A/B — with a genuine desert reference (composite donor `desert2/3.dds` tiles as
  ground truth, or a real desert screenshot from the reference set), re-runs the
  visual comparison and appends a REVOKED/REVISED section to its report. I
  personally re-opened the current PNG and confirmed: PORT side substantially
  improved (stamp lattice gone, clustered cracked patches, boulder + contact
  shadow), donor panel degenerate. Relayed both conditions to the T15 child.
  T15 remains excluded from the integration count until QA confirms condition 1
  AND condition 2 lands AND I re-verify the new sheet and request final clear.
- **T15 final status (2026-11-23):** coordinator issued the final ruling on
  condition 1 — QA T6-Q04 independently reproduced the scale artefact and
  confirmed v4 exactly; C5 RED cleared on metrics as a P-45-class wrong-method
  case (not wrong data), with the engine 250 ms sub-item transferred to T90.
  Condition 2 then landed: the child replaced the degenerate strip with a labelled
  2×2 contact sheet of genuine donor desert6/2/3/4 tiles (centre crop 256,256,768,768).
  I personally re-opened the new compare PNG and confirmed a VALID donor ground-truth
  panel with no wooden siding, UI or metallic object; the port render SHA is unchanged
  so QA's metric result still applies. Honest residual visual gaps recorded in the
  child's REVISED report section. I queued a final-clear request to the coordinator;
  I have NOT self-cleared T15, so it stays excluded from the count until ruled.
- **T15 FULL PASS / D-32 (2026-11-23):** coordinator final clear after QA Q04
  conditions 1+2; lane count became 1/15. Named non-blocking residual transferred
  to T90 owner review: port patches softer/stained vs donor `desert2/3` sharper
  polygonal plates, `desert6` finer hairline cracks — an improvement item, not a
  silent gap. Engine 250 ms bake sub-item also transfers to T90 gates. Coordinator
  directive: hold this complete loop standard for every remaining piece.
- **T04 C7 probe route escalated (2026-11-23):** I personally re-opened the new
  compare + dark-probe PNGs — dark right-edge band and concentric arcs are gone,
  donor #12 panel valid. C7 depth colour is now shown only on a labelled separate
  probe (main tile correctly has no dark water because donor #12 has none). Rather
  than self-accept an acceptance-scope change, I queued a coordinator ruling on
  whether the probe satisfies C7 or C7 must be re-scoped; T04 stays QUALIFIED and
  excluded. Child agreed not to reintroduce a dark band to force a pass.
- **T03 PASS / parent intake verified (2026-11-23):** child claimed 12 PASS / 0
  FAIL; I personally re-opened the current compare and facecrop PNGs. The donor
  crop `(840,360,1100,480)` genuinely contains an eroded rock face (no UI/minimap),
  and the port no longer shows the four named defects (no wooden-plank uniformity,
  no black contour, no perfect zigzag, no flat lighting). Counted as full PASS;
  open items (`rock_stones1` missing, camera-fixed capture at combo) recorded.
- **T07 HOLD (2026-11-23):** child claimed "PASS (cautious)" but its own report
  has 9 PASS / **1 FAIL** (2 of 8 luminance bins vs ≥4 target) / 2 UNVERIFIABLE
  (whole-map flat-top %, keep-clear → T90 dump verifier). I personally re-opened
  the compare PNG: donor panels contain the plateau/rim feature, no UI/minimap.
  A FAIL cannot be an unconditional PASS under the binding rule. Queued to the
  child: revise the headline to CONDITIONAL/HOLD in a REVOKED/REVISED report
  section, then either genuinely satisfy the bin criterion or request P-45-class
  adjudication through me with donor crop coordinates, bin method, L std/hi-freq
  and bin occupancy, and an explanation of why the criterion conflicts with the
  donor clean plateau. T07 excluded from the count until ruled.
- **T10 spawned (2026-11-23):** `ses_df8005355ffeJKNIwdnY66J5D9` on
  `opencode-go/hy4-flash-free`, filling the slot freed by T03 completion; its
  prompt carries the binding valid-donor-crop rule and the defect list.
- **T01 full PASS accepted (2026-11-23):** parent re-opened the revised compare
  PNG; child correctly pointed out that the earlier "camouflage blob" critique
  used the clean-grass NEGATIVE CONTROL while the mottled spec requires std 30–40
  and broad tonal regions. Octave/fine-grain rework is visible (hf 8.06→10.58,
  grid_peak 0.147→0.083), 11 PASS / 0 FAIL intact, donor crops valid. Accepted
  the retained tonal-region scale as intrinsic to the mottled contract — no
  C1/C3 spec revision needed. Counted; ~1.8% yellow tips logged for combo.
- **T05 rebuilt + final-clear request (2026-11-23):** child admitted its earlier
  FIXED labels were a false claim (code executed but 57 near-black rim pixels
  remained), appended a REVOKED section, and rebuilt as an R3 winding gully with
  module version `T6T05-R3-ORGULLY-20261123` + source SHA embedded in every PNG;
  100% pixel diff vs the previous render proves execution. Parent personally
  re-opened the new compare: all four named defects addressed, donor crop
  genuine, all numeric bands pass; residual single-gully/no-tufts disclosed.
  Because it was REVOKED by the coordinator, I requested a final clear rather
  than self-promoting it; T05 stays excluded until ruled.
- **T07 adjudication relayed (2026-11-23):** child revoked its cautious PASS and
  supplied P-45-form donor proof (clean plateau crop has 2 bins at std 8.057,
  relief crops have 4 bins at std 20.9–26.2; 4 bins would force std ≳17 and
  break the same criterion's std ≤10). Parent relayed the request to the
  coordinator; T07 stays CONDITIONAL/HOLD and excluded until ruled.
- **All 15 tickets spawned (2026-11-23):** T11 `ses_df7fb6afbffe9e92R2ODANG9SM`
  and T13 `ses_df7fb6686ffer9tpLTEmfm7ESQ` on `opencode-go/hy4-flash-free`,
  each with the binding valid-donor-crop rule and defect list in its prompt.
  Active workers now: T02, T06, T08, T09, T10, T11, T13 (≤8 direct children).
- **T12 REVOKED / arbitration relayed (2026-11-23):** I personally re-opened the
  corrected compare sheet: the donor panel is now labelled donor mine sprite art
  (`mine_gold`, olive disc keyed out) with an explicit non-screen-match disclaimer
  — valid per the coordinator directive since no catalogued reference contains a
  mine. Mirror-tiling is gone, mine is legible with a directional contact shadow.
  But the child honestly reports visual FAIL (flat 2D proxy, no engine lighting)
  and A6 FAIL (3.91 tiles, component = whole clearing), and I noted the clearing's
  hard near-rectangular edge against grass. I relayed the child's A6
  prop-footprint-vs-worked-apron metric-definition arbitration and asked whether a
  sprite-art A/B can pass at piece scope or whether T12 must wait for T90 engine
  lighting. No self-clear; T12 stays REVOKED/excluded.
- **T09 HOLD (2026-11-23):** child reported 7 PASS / 1 PARTIAL / global gate PASS.
  I personally re-opened the compare sheet: donor panel `[180,200,340,340]` has
  cavalry/unit formations (contamination class), and the report's PARTIAL criterion
  (conifer wide_frac 0.347 at rendered-component scale vs ≤0.30; source sprites
  pass) blocks unconditional PASS. Queued to the child: clean unit-free donor
  crop or composited broadleaf ground truth, fix or P-45-adjudicate the wide_frac
  scale question through me, append a REVOKED/REVISED report section. Excluded.
- **T08 HOLD (2026-11-23):** child reported 8/8 ranked PASS with genuine density
  (212 trees, three size buckets) and soft directional contact shadows, but I
  personally re-opened both compare sheets: the dense #11 donor panel contains a
  minimap/UI panel and unit formations, and the #8 primary panel contains troops
  — both invalid under the binding donor-crop rule. The supporting global HSV
  gate is also unmet (sat 0.551, val 0.207). Queued to the child: clean or
  composited donor panels, REVOKED/REVISED report section, and either meet the
  gate or provide formal P-45 donor-measurement proof for adjudication through
  me. T08 excluded from count.
