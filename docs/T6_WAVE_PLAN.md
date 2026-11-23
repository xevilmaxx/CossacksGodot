# T6 WAVE PLAN — donor-quality gap analysis + recursive swarm (2026-11-23)

Owner directive (2026-11-23): analyze done-vs-not-done against the donor
(`C:\Games\Cossacks 3`), restructure the swarm as an **infinite recursive tree
of micro-agents** (SWARM_OPS.md §7), fix graphics fidelity **piece by piece**
(many mini-bakers, each testing its own piece before any whole test), with
terrain the top dissatisfaction and some units second. Optionally open a
**pure-Rust, zero-third-party-GUI, natively multiplatform** branch in a
dedicated subfolder, worked in parallel. Final objective: a Cossacks 3 clone
as similar as possible to the donor.

Protocol: `SWARM_OPS.md` §7 (recursive tree, models, supervision, ownership).
Worker mechanics: `app/tools/AGENT_PROTOCOL.md`. Quality rules: §5b-QUALITY.

---

## 1. Gap analysis — what is DONE vs NOT DONE vs donor quality

### 1.1 DONE and verified (cited)

| Area | State | Evidence |
|---|---|---|
| Sim rules | 29/29 selftest, 17/17 uitest; 182 donor-documented values (damage formula, 1.664/s mines, /625 upkeep, famine, capture, market drift) | `app/mechanics.json`, `app/MECHANICS.md`, board FINAL VALIDATION (jobs 1034–1036) |
| Formations / squads | 15–400 ladder, 149 verified donor bonus tuples, morale/routs, officers+drummers | board P-30, P-40 (`t_squads` 5/5) |
| Multi-AI skirmish | N players/teams, donor SetupMines per start, recruit modifiers (Shift+5, Ctrl endless…), spawn stagger | board P-18/P-42/T5-GEN (`t_multi_ai` 6/6) |
| AI opponent | food-reserve gate, mill-first build order, no famine in 3×300 s soaks | board T5-AI-FIX, `docs/audit/AI_SURVIVAL_DIAG.md` |
| Unit assets | 54 keys / 299 action sheets baked from donor `.oss`/`.aaf`, real per-action metrics, 51/51 attack durations donor-exact | `ASSET_AUDIT.md`, `docs/UNIT_BAKING_FIX.md`, board P-34 |
| Building assets | 215 nation sheets + 18 Scottish, stages/rubble | board P-41 (`t_roster_scotland` 6/6) |
| Terrain generator | donor 124-slot TileBlock + SmoothTileMap chains, stamped relief (h≤2.964), forest 45.6%, rock 6.8%, patches 75, determinism byte-identical | board T2 GEN / T4-DONOR-BLEND / FINAL VALIDATION, `scan_map.py` ALL GREEN |
| Ground render | exact per-cell donor block coverage, grid_peak 0.063 ≈ donor 0.064 (checkerboard eliminated) | board T4-BLEND (`t4blend_land.png`) |
| Water shader | donor equation re-port: deep colour ±1.6 levels, ACF lag1 0.67, glints 0% | board T2-BUILD-WATER, `docs/audit/WATER_REPORT.md` |
| Audio | 20 nation tracks, work/ambient families | board P-13, FP-6 (`t_audio_events` 5/5) |
| Perf | chunk bake max 50–220 ms < 250 ms gate; all chunks resident w/ LOD | board QA-P1, T5-RENDER |
| Infra | FIFO runner (500 jobs), clean gate, piece renderer + 21 piece specs, 20480² full-map compositor, geometry verifier (13 PASS / 0 FAIL / 10 UNVERIFIED) | `docs/STATUS_TESTS.md`, board T2/T3 |

### 1.2 NOT DONE / below donor — the owner's dissatisfaction, ranked

**A. Terrain graphics (top priority).** Honest status from T2 wave close
(board): *"measurable fidelity improved substantially, but still NOT donor-equal"*.

| # | Gap | Evidence |
|---|---|---|
| A1 | Grass mottling coarse/blotchy; gain overshoot vs donor ±25–35 L terrain-driven patches | `verdict_grass_relief.md` (grass_mottled 4/4 FAIL), T2 close |
| A2 | Shore: stair-step tile edges, wrong sector windows, wash band / cellular veins; rim 8 px vs ≤3 px target | `verdict_shore.md`, T2 close, T2RENDER_REPORT |
| A3 | Rock area 6.8% vs donor reference 8–18%; ravine flute anisotropy; repeating rock texture | TB-V1 spec, `verdict_grass_relief.md`, T2 close |
| A4 | **Water effects NOT acceptable (owner explicit):** no reflection, no true 9-octave fBm, glints/shimmer approximations | T2 wave directive item 5, `WATER_REPORT.md` 18-row gap table, `RENDER_ARCH_REFLECTION.md` |
| A5 | Winter = tint-only (27 blocks unwired); desert = flat tint vs 12 donor palettes | TB-A2, `desert_variant.md`, `winter_variant.md` |
| A6 | Trees: broadleaf only ~14%, oak sat 0.97 vs muted olive-lime; bushes/stumps sprite fallbacks; only part of 15 forest families reachable | `forest_broadleaf.md`, TB-A4, verdict_decor |
| A7 | Hills are round paraboloids vs donor ridges/ravines/plateaus; hill mask occupancy ignored; slope 0.165 < 0.5 cliff threshold → green flanks | TB-A3, `hill_ridge.md`, `plateau.md` |
| A8 | Mines display 4 remaining fixes; field stalks/decal verification | `mines_display.md`, verdict_decor (mines 3/4) |
| A9 | Full-map PNG is a diagnostic compositor, NOT in-engine shader/lighting; no shadows, weather, seasons in engine | T2-INFRA-2 caveat, board P-21 |
| A10 | Structural: donor = 3D perspective lit heightfield (shadows, normal maps, PCF, fog); port = 2D composite. 3D sandbox M0 closed as visual FAIL — 2D stays shipping path, but the depth/lighting gap is the root of "not donor-equal" | `RENDER_ARCH_SYNTHESIS.md`, R-ARCH wave |

**B. Units (second priority).** Metrics are donor-exact but the owner still
sees visual defects in some units; bakes were done monolithically
(`bake_sprites.py`) — owner wants **many mini-bakers, piece-by-piece verification**.
Naval layer beyond yacht is open (P-10). Mass-army scale 200 vs donor thousands
(P-22). `.obj` conversions are bind-pose, no normals/anim (asset debt for any 3D mode).

**C. FX / HUD / misc.** Impact FX + full shadows/weather open (P-20/P-21);
first-seconds chunk-bake glitches on minimap jump (T2-NAV proposals partially
built); HUD fidelity partial; campaign/multiplayer DEFERRED by charter (§0).

**D. Rust branch.** Does not exist yet — opened by this wave (`rustport/`).

### 1.3 Strategy consequences

1. **Piece-first** (owner): single-piece headless renders → verify vs donor
   truth → combos → small map → full-map confrontation. Already partially
   built (T2): 21 specs + `terrain_piece_render.py`. T6 converts every
   remaining FAIL into a micro-ticket with its own mini-baker.
2. **No monolithic bakes:** unit re-verification happens per family in
   `app/tools/unit_bakers/<family>.py`, staging outputs, frame-by-frame donor
   checks BEFORE any roster-wide bake or live-asset change.
3. **Water gets a dedicated lane** (owner: not acceptable yet).
4. **Rust branch in parallel**, fully disjoint (`rustport/**`), own engine/GUI,
   no third-party GUI libraries, native multiplatform.
5. Research lane fills the UNVERIFIED gaps (camera/projection, heightfield
   resolution, water sampler bindings, smoothing-chain coverage) so builders
   stop approximating what could be known.

---

## 2. Lanes, ownership and micro-tickets

Models: parents `opencode/hy4-flash-free#high`; workers `opencode/hy4-flash-free`;
escalation `opencode-go/muse-spark-1.3-contributor#high` (SWARM_OPS §7.2).
Every ticket = one worker + disjoint owned outputs + report
`docs/t6/reports/<ID>.md`. Lane docs: `docs/t6/<LANE>_LANE.md`.

### LANE TERRAIN (parent T6-TERRAIN) — lane doc `docs/t6/TERRAIN_LANE.md`

Shared READ-ONLY: `app/tools/terrain_piece_render.py`, `app/tools/piece_specs/*.json`,
`app/scripts/world.gd`, `app/scripts/game.gd`. Donor truth: `C:\Games\Cossacks 3\data\`
+ reference images `C:\Users\Maxym.Oboyshev\Downloads\c3\` (primary target
`cossacks-3-v1-498085.jpg`, specs in `docs/audit/TERRAIN_REFERENCE_IMAGES.md`).
Each mini-baker owns: `app/tools/pieces/t6_<name>.py` (new), its piece spec/verdict
doc under `docs/audit/PIECES/` (append), outputs `app/shots/pieces/t6_<name>*`.

| ID | Micro-task | Acceptance (from existing specs/verdicts) |
|---|---|---|
| T6-T01 | grass_mottled mini-baker | terrain-driven ±25–35 L, ≥4 tonal patches/200², no coarse blotch (FFT grid_peak <0.20) |
| T6-T02 | shore_sand mini-baker | donor 8×45° sector fold, 3 sandsea tiles, dry-sand base, rim ≤3 px, no stair-step |
| T6-T03 | shore_rock mini-baker | rock8 fill + rock1 flutes (arbitration doc), anisotropy ≥3, lit/shadow ≥1.8 |
| T6-T04 | shore_water_transition mini-baker | wash band 30–50 px, shallow #C3D1CA gate, foam specks, no flat teal |
| T6-T05 | ravine_face mini-baker | rock area 8–18% of ravine view, rim ≤3 px, flute anisotropy per spec |
| T6-T06 | hill_ridge mini-baker | mask occupancy respected, aspect ≈1.69, cliff flanks not green |
| T6-T07 | plateau mini-baker | h cap 2.964, walkable ramp, rock face present |
| T6-T08 | forest_conifer mini-baker | remaining 2 FAIL criteria of verdict_decor (conifer 3/5) |
| T6-T09 | forest_broadleaf mini-baker | oak muted olive-lime (sat per spec), broadleaf share per spec, trunk B/G ≈0.74 |
| T6-T10 | bushes_understory mini-baker | real bush/stump sprites (no rock fallback), density per spec |
| T6-T11 | stones_rocks mini-baker | regression-keep 4/0 + density/size buckets per TB-V1 |
| T6-T12 | mines_display mini-baker | 4 remaining mine fixes (verdict_decor mines 3/4) |
| T6-T13 | field_crops mini-baker | donor alpha footprint (17,19,494,494), vertical stalks hue 39–45°, no sunflower heads |
| T6-T14 | winter_variant mini-baker | 27 winter blocks wired in piece renders (not tint-only) |
| T6-T15 | desert_variant mini-baker | 12 donor palettes, dry rock grade (not green mossy) |
| T6-T90 | INTEGRATION (gated, coordinator-granted, ONE builder owns world.gd) | only after ≥12/15 pieces PASS + owner visual review; gates 29/29+17/17+bench+scan |

### LANE UNITS (parent T6-UNITS) — lane doc `docs/t6/UNITS_LANE.md`

Shared READ-ONLY: `app/tools/bake_sprites.py`, `compute_ortho.py`, `sheet_metrics.py`,
`app/assets/models/anim/**` (live). Donor truth: `.oss`/`.aaf`/`.osm` under
`C:\Games\Cossacks 3\data\`, format docs `docs/UNIT_BAKING_FIX.md`, `docs/decomp/DC_FORMATS.md`.
Each mini-baker owns `app/tools/unit_bakers/<family>.py` + staging
`app/shots/unit_pieces/<family>/` + report. **Bake ONE unit first, verify
frame-by-frame vs donor AAF (durations, foot pin, attach props, per-action
camera), then the rest of the family.** Max 2 concurrent Blender bakes
project-wide — parent arbitrates slots.

| ID | Family (keys from anim/index.json) |
|---|---|
| T6-U01 | peasant + 8 national peasants (ukr/rus/pol/aus/eng/spa/tur/sco) |
| T6-U02 | 17c infantry: pikeman, roundshier, serdiuk, archer, strelet, cossack, pandur, croat, chasseur, highlander, jannisary |
| T6-U03 | 18c infantry: musk18, pikeman18, musketeer, grenadier, lightinfantry |
| T6-U04 | cavalry: dragoon, dragoon17, hussar, wingedhussar, cuirassier, reiter, lightcavalry, hackapell, tatar, sipahi, spakh, mameluke, vityaz, hetman, cossackdon, cossackregister |
| T6-U05 | artillery: cannon, howitzer, mortar, multicannon |
| T6-U06 | support: officer, officer18, drummer, drummer18, priest, pope, padre, mullah, bagpiper |
| T6-U07 | naval (continue P-10): yacht + readable naval meshes per NAVAL_EVIDENCE.md |
| T6-U90 | INTEGRATION (gated): verified staging sheets → live anim + index.json, ONE owner, gates |

### LANE WATER (parent T6-WATER) — lane doc `docs/t6/WATER_LANE.md`

| ID | Micro-task | Owned outputs |
|---|---|---|
| T6-W01 | Donor shader equation re-verification + UNVERIFIED sampler bindings (read donor shaders/scripts; `WATER_REPORT.md` baseline) | `docs/t6/reports/T6-W01.md` |
| T6-W02 | Headless water mini-baker: 9-octave fBm, depth colour, donor glint statistics, foam | `app/tools/pieces/t6_water.py`, piece PNGs |
| T6-W03 | Reflection proxy design (projected texture per RENDER_ARCH_REFLECTION; no cubemap) | report doc |
| T6-W04 | INTEGRATION (gated on W02 PASS): ONE builder owns `app/shaders/water_overlay.gdshader` (verified path; backups `.bak-T2W`/`.bak-T3S`); gates via runner | shader + captures |

### LANE RUST (parent T6-RUST) — lane doc `docs/t6/RUST_LANE.md`, owns `rustport/**` ONLY

Pure Rust, **zero third-party crates for GUI/windowing** (raw platform FFI is
allowed and required: Win32, X11/Wayland, Cocoa). Natively multiplatform.
Reads donor assets at runtime from the install path (private use, same licence
rules). Reuses documented knowledge: `app/mechanics.json`, format docs, piece
specs. Does NOT touch the Godot app.

| ID | Micro-task |
|---|---|
| T6-R01 | Scaffold: cargo project, no deps, build/run docs, architecture doc (engine modules: platform, raster, assets, sim, gui) |
| T6-R02 | Win32 platform layer: window + input + software framebuffer present (raw FFI, no crates) — testable on this machine |
| T6-R03 | X11/Wayland platform layer (compile-checked; runtime UNVERIFIED on this host — label honestly) |
| T6-R04 | macOS/Cocoa platform layer (same honesty rule) |
| T6-R05 | Asset readers: DXT1/3/5 DDS, `.oss`, `.osm`, `.aaf` — port from the proven Python readers, byte-compare tests |
| T6-R06 | Software rasterizer + terrain tile renderer (donor blocks, height shading) |
| T6-R07 | M0 visual gate: 16×16-tile terrain capture A/B vs donor reference; owner review before anything else |
| T6-R08 | Sim core skeleton from mechanics.json (economy tick, gather, upkeep) + headless tests |

Order: R01 → R02 → R05/R06 → R07 (M0 gate) before R03/R04/R08 expand.

### LANE RESEARCH (parent T6-RESEARCH) — lane doc `docs/t6/RESEARCH_LANE.md`, read-only

| ID | Question (UNVERIFIED today) | Output |
|---|---|---|
| T6-S01 | Which projection branch drives the donor main view; heightfield resolution | `docs/research/T6_S01_camera.md` |
| T6-S02 | Water sampler→texture-unit bindings in cossacks.exe (strings/RTTI/CA) | `docs/research/T6_S02_water_bindings.md` |
| T6-S03 | tilesmooth_scripts.cfg: all 22 chains vs port's 10 Summer chains — what's missing per season | `docs/research/T6_S03_smooth_chains.md` |
| T6-S04 | Web: GSC engine details, community RE, wiki mechanics not yet in mechanics.json | `docs/research/T6_S04_web.md` |
| T6-S05 | Per-action animation truth for families the owner flagged (frame counts, durations, attach props) | `docs/research/T6_S05_anim_truth.md` |

### LANE QA (parent T6-QA) — lane doc `docs/t6/QA_LANE.md`

| ID | Micro-task | Owned outputs |
|---|---|---|
| T6-Q01 | Piece-verdict registry/aggregator: scans `docs/t6/reports/*.md` + piece manifests → dashboard | `app/tools/t6_registry.py`, `docs/t6/DASHBOARD.md` |
| T6-Q02 | Integration gate desk: runs selftest/uitest/bench/scan/full-map confrontation when T90/U90/W04 land (runner ids `t6qa-*`) | gate reports in lane doc |
| T6-Q03 | Liveness watch: `worker_health.py`, runner status, orphan check; reports stalls to coordinator | lane doc §health |

---

## 3. Coordinator duties this wave

- Spawn the 6 lane parents; supervise per §7.3; escalate stuck parents to
  `opencode-go/muse-spark-1.3-contributor#high`.
- Grant integration tickets (T90/U90/W04) ONLY when piece PASS evidence exists;
  one builder per shared file; update the board state column.
- Owner visual review at combo/full-map milestones — metrics never override it.
- Keep `SWARM_BOARD.md` §T6 and this plan current; every lane keeps its own doc.