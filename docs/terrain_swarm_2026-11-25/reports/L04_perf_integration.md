---
id: L04-PERF-INTEGRATION
ticket: "INTEGRATION wave — L04 — ordered, conflict-free performance integration plan"
owner: L04 (read-only integration agent)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_SOURCE_EDIT
labels: [observed, derived, inferred, UNVERIFIED]
scope: "Exactly one repo file written: this report. No .gd/.gdshader/config/test/fixture/tool/result/queue edit; no Godot process or runner job; no backup created. All source state read from the on-disk tree at HEAD 8e9de1bf."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
inputs: [G04_gate_log.md, G17_perf_audit.md, P01..P16 reports, M03_mill_fix_proposal.md, M04_mill_qa.md, F2_01..F2_05 reports, S01_speed_audit.md, S02_speed_fix.md, H07_2d_reuse.md, B01..B06 reports, WAVE_G_CHARTER.md, SWARM_BOARD.md]
parity_guard: "No donor GPU A/B frame exists. No FPS, frame-time, draw-call or 'donor parity' result is asserted by this plan. Every benefit tier below is an INFERRED expectation derived from the cited static audits; measured FPS remains UNVERIFIED until a real P09-protocol run by G04."
---

# L04 — ordered, conflict-free integration plan for the performance fixes

## 0. Standing rules for this plan (binding on whoever executes it)

- **No FPS claim without a real run.** No windowed FPS number exists anywhere in this
  session: headless telemetry records `draw_calls_avg=0.0`/`frame_delta_ms_avg=0.0`
  (`P02_draw_calls.md:47-59`), and the existing windowed captures store pixels, not
  frame times (`P09_measurement.md:28-43`). Every tier in §2 is **INFERRED** from
  source counts and is a *ranking*, not a measurement.
- **No donor parity claim.** All fixes are PORT APPROX / output-identical-by-derivation
  arguments only (`CHARTER.md:55-58,124-130`). A green gate never establishes parity.
- **Only G04 submits runner jobs** (`WAVE_G_CHARTER.md:31,67-70`). This plan submits
  none. `python`, not `python3`; `;` not `&&` (`CHARTER.md:69`).
- **Backups before every edit**, named `inbox/backup/<file>.bak-<TICKET>`
  (`CHARTER.md:66`, `WAVE_G_CHARTER.md:87`). For contested files a **fresh** backup
  must be taken *at the moment ownership is handed over*, so it snapshots all earlier
  landed fixes; restoring an older backup would silently roll back those fixes too.
- **One exclusive owner per file at any moment** (`CHARTER.md:67-68`). The handoff
  table in §4 is the authority; a grant ends only when that owner's tranche is gated
  and its backup/hash record is filed.
- **No test weakening**: no threshold, assertion, fixture, `expected_pre_fix_failure`
  or capture gate may be edited to make a fix pass.

### Current on-disk state (OBSERVED, `git status --short`, HEAD `8e9de1bf`)

Only Wave-B edits are applied: `game.gd` (B03), `tile_atlas_loader.gd` (B02),
`input_controller.gd` (B05), `world3d_fx.gd` (B06), `terrain_tileindex.gdshader`
(B01), two atlas `.import` files, `t_select_rect.gd` plus test-result JSONs.
`world3d_terrain.gd` is **clean** — B04 was fully reverted
(`B04_relief_impl.md:7,18-20,88-99`). **No `.bak-P10`…`.bak-P16`, `.bak-M03`,
`.bak-F2-*`, `.bak-S02` or `.bak-H07` exists**: every P/M/F2/S/H performance fix in
this plan is still only a *proposal*. "All proposals landed" means all *reports*
landed; no performance diff has been applied yet.

---

## 1. Performance evidence already on record (read from `G04_gate_log.md`)

This is the only real execution evidence; it is reported verbatim in substance and
used only to rank risk — never to claim FPS.

| Gate (G04) | Ticket | Result | What it licenses |
|---|---|---|---|
| selftest | 584 | **ok / 0**, 29/29 fresh, `SCRIPT ERROR=0`, 228.67 s | Baseline sim gate is green on the current tree. |
| `t_render_mode` | 586 | **ok / 0**, 10/10, `result=PASS`, `seam_missing=false`, 16.87 s | 2D default gate green. |
| windowed P0 | 588 | **ok / 0**, 1280×720 non-blank, `mean_luma=92.134`, `full_width_dark_rows=0`, `SCRIPT ERROR=0` | Current visual anchor exists. |
| windowed real-map | 589 | **ok / 0**, 1280×720 non-blank, `mean_luma=83.828`, `full_width_dark_rows=0`, `SCRIPT ERROR=0`, seed 20261113 | Current real-map anchor exists. |
| **uitest** | **585** | **timed-out / -9**, 308.54 s (300 s limit); stdout shows `_setup_full_game → bind → build → _load_masks` warnings repeating; `[runner] KILLED after 300.0s`; `SCRIPT ERROR=0` | **Not a PASS.** A setup/loading performance defect, not a failed assertion. |
| **uitest re-run** | **587** | **failed / 1** at 138.30 s (600 s runner limit); `watchdog: wall-clock limit reached, forced exit`; `WARNING: 3 ObjectDB instances were leaked at exit`; `ERROR: 1 resources still in use at exit` — **engine** errors, `SCRIPT ERROR=0` | **Not a PASS.** `main.gd:209,210-212,1588-1591` applies a ~120 s default `--ui-test` watchdog, which fired before the runner limit. |

**Critical honesty point (`G04_gate_log.md:197-211`):** the on-disk `uitest.json`
reads `passed=true`/17-of-17 but has `LastWriteTime = 2026-11-25 13:30:42`, which
**predates both jobs**; both job stdouts contain only the Godot version banner.
Therefore **17/17 is stale, not fresh evidence**. No integration step may cite it as
a passing gate. This must be repaired or explicitly waived by COORD before any HUD,
speed-option or loader change is accepted (it directly gates P12, S02 and P15).

**Derived reading (INFERRED):** the watchdog hit during `bind → build → _load_masks`
corroborates the loading-path diagnosis (`P06_loading_path.md:58,75-128`;
`G17_perf_audit.md:59-71,126-145`): one synchronous "Loading art..." stage body owns
the main thread while a 180 MB PNG decodes, a ~171 MiB mip chain is built, and a
~683 MiB texture is handed to the GPU. This is the strongest argument for doing the
loader tranche early — but it is a *watchdog/timeout observation*, not a measured FPS
or build-time number.

**Measurement protocol to use for any benefit claim:** `P09_measurement.md` §3–§7 —
one warm-up per fixture discarded, interleaved `B/A/B/A/B/A` (3 before + 3 after) per
fixture, primary metric `Time.get_ticks_usec()` delta at `frame_post_draw`, report
`Δp50` and `Δp95` of `wall_ms` separately, never compare Path S (unfocused, vsync off)
with Path I (focusable, vsync on) in one column, and raise to 5+5 if run-to-run spread
exceeds ~5 %/10 %. Verdict stays `MEASUREMENT_ONLY__NO_PASS_CLAIM`.

---

## 2. Candidate-fix register

Benefit tiers are **INFERRED** expectations from the cited reports, not measurements.
"Risk" means risk to the visual/test gates in `CHARTER.md:122-130` and each ticket's
acceptance list. Rollback is always a full-file restore from the named backup taken
*at handover*; partial re-application to "make a gate green" is forbidden.

| ID / candidate | Exact exclusive owner file(s) | Prerequisite before grant | Benefit tier (INFERRED) | Visual/test gate risk | Rollback path |
|---|---|---|---|---|---|
| **P13-W1+W2** — water foam band gate (`water3d.gdshader:238-239`) + `noise()` `fract` drop (`:74`) | `variant3d/shaders/water3d.gdshader` | G04 gates accounted; COORD grant; shader clean (it is, `git status`) | **HIGH (INFERRED GPU-fragment)**: 6 fetches + 2 `pow` + up to 66 `fract` removed per fragment (`P05:255-284`); only on water-covered pixels | **MED**: `t_terrain_shore` contract (single plane, `WATER_LEVEL=-0.25`, `no_port_art_shore_prox`); pixel equality of wrap at GLES3 **UNVERIFIED**; needs windowed A/B at identical camera/time | Restore `inbox/backup/water3d.gdshader.bak-P13`; re-run shore atom |
| **P13-W3** — gated early dry discard (between `:169`/`:170`) | same file, same owner continues | Above **plus** W1/W2 capture reviewed; `waveheight<=0.0` gate is non-negotiable | **HIGH (INFERRED)** on dry full-map-plane fragments: 12 fetches + 10 `sin` worst-case; early-Z interaction **UNVERIFIED** (`P05:157-166`) | **MED-HIGH**: must not flip `EXPECTED_PRE_FIX_FAILURE` at `t_terrain_shore.gd:915-924`; a future surface-Y A/B would break if ungated; capture required | Restore `.bak-P13` (or re-apply W1/W2 patch after restoring) |
| **P08 overlay** — 3-key weak-GPU config (`fx_cap=60`, `fog_interval=1.5`, `minimap_interval=1.0`) | NEW `variant3d/config_weak_gpu.json` (COORD/temp; **no source file**) | COORD creates overlay as third `--config` layer; pin seed/map/zoom/quality=high | **MED in play / LOW at start (INFERRED)**: `fx_cap` and fog are idle at start (FX=0, `FOG_OF_WAR=false`); only minimap cadence is live (`P08:24-49,106-116`) | **LOW**: no source edit; `quality` stays `high` so mapgen art is unchanged; `t_smoke_fx` needs only `cap>0`; do not write gate-sensitive defaults into shipped `config.json` | Delete overlay / drop `--config`; zero source rollback |
| **P10** — cross-frame morph cache + `_qmat_into` scratch + `_range_cache` (`anim3d.gd`) | `variant3d/scripts/anim3d.gd` | G04 gates; COORD grant; reconcile cache key/bound with landed P03 (`P03:197-243`) and P10 §7 #6; byte-digest check for `skin_vertices` | **MED (INFERRED)**: ~50 % of per-key skinning at 60 fps from historical 0.58–0.80 ms/sample; ≈1.7–2.4 ms/frame at 200 units is an extrapolation, **UNVERIFIED now** (`P03:245-250`, `P10:101-105`) | **MED**: `t_motion_capture.gd:234-244` pose fields must stay identical; `_qmat_into` bit-identity **UNVERIFIED**; shared read-only pose safety | Restore `inbox/backup/anim3d.gd.bak-P10` |
| **P15-A + B2/C + world3d handoff** — worker-thread atlas mips, async bind chain, readiness assertion | `tile_atlas_loader.gd`, `world3d_terrain.gd`, `main.gd`, **plus** required `world3d.gd` handoff (`P15:523-556`) | G04 gates **and a decision on stale uitest**; one integrator granted all four files; ALL four backups; re-read current `main.gd` (LOAD-ASYNC-01 already landed) | **HIGH (INFERRED) for startup responsiveness / owner S3**, **not steady-state FPS**: moves ~683 MiB mip build off main thread (`G17:126-145`, `P06:223-242`) | **HIGH**: thread-safety of `Image.generate_mipmaps`, `await` on dynamic calls, upload timing all **UNVERIFIED** (`P15:599-604`); window title-bar drag test at "Loading art..." required; `load_ready` assertion may need narrowing, not deletion | Restore all four `.bak-P15` / `.bak-P15-HANDOFF` files in one pass |
| **P15-B1** — byte-level swizzle + SHA-keyed mask repack | `world3d_terrain.gd` (same P15 integrator) | Same as P15 above | **MED (INFERRED, rebuild only)**: 655,360 `get_pixel`/`set_pixel` pairs → one cache hit; no first-build saving (`P15:280`, `P16:335`) | **LOW-MED**: output claimed byte-identical by derivation, but atlas sampler/grid/mesh must be re-verified; cache key must not collide | Restore `world3d_terrain.gd.bak-P15` |
| **P16 subset** — build-loop invariant hoists (`named_cells`, `tids` alias, row `zc/zuv`, `relief_span`, dict aliases) | `world3d_terrain.gd` | **P15 released the file first**; re-derive hunks against post-P15 tree, not the B04-modified snapshot P16 was written against (`P16:31-35`) | **LOW (INFERRED)**: fewer interpreter ops, no FPS claim; `stats.timing_ms.mesh_build` only (`P16:333-341`) | **MED**: B04's contour regression shows this file is visually explosive; `_face_mode_at()`/`_relief_face_at()` must stay byte-identical; 1/4096/7938/4096 invariants | Restore `inbox/backup/world3d_terrain.gd.bak-P16` (fresh, from post-P15 tree) |
| **P14** — fog quad compaction (skip alpha-0 / mode-off tiles) | `variant3d/scripts/world3d_fog.gd` | COORD grant (file currently has no owner); backup | **LOW (INFERRED)**: **expected zero at shipped start** because `FOG_OF_WAR=false` → overlay already invisible `[D]` (`P14:62-67`); MED only when fog enabled and partially revealed | **MED**: `t_fog3d` 9 checks must stay; `_v716_probe` surface count would read 0 with fog off (non-manifest, COORD decision); internal `_tile_alpha` staleness caveat `P14:423-431`; added full-map rebuild cost | Restore `inbox/backup/world3d_fog.gd.bak-P14` |
| **P11** — shared tint `Shader`/`ShaderMaterial`, 64-slot growing MultiMesh, additive stats | `variant3d/scripts/world3d_entities.gd` | G04 gates; **M03 and F2-03 not holding this file**; backup | **MED (INFERRED)**: removes per-batch `Shader.new()` and 4096-slot reservation (~12 MB VRAM) but **does not lower draw-call count**; Tier-2 building batching explicitly deferred (`P11:60-71`) | **MED**: `t_entities3d` peak=6, `t_terrain_trees`, morph/teleport continuity, field colours on resize; `world3d_entities.gd.bak-BT2B` exists but is **not** P11's backup | Restore `inbox/backup/world3d_entities.gd.bak-P11` |
| **P12** — HUD per-frame cost reduction (H1–H4) | `hud.gd`, `hud3d_adapter.gd` | G04 gates **including a fresh uitest**; COORD grant before S02; two backups | **MED (INFERRED)**: removes 4 ray casts + ~15–18 string formats/frame on idle frames (`P04:143-149`, `P12:73-82`) | **MED-HIGH**: `t_hud_layout` 62 checks at 1024/1280/1920, `t_hud_fidelity`, UI-TOPBAR-01 literals, stale-17/17 problem; status line becomes 2 Hz (documented behaviour change) | Restore both `.bak-P12` files |
| **P02-A2** — batch/cache selection rings (3N → 3 draws) | `variant3d/scripts/world3d_fx.gd` (no current owner) | **New ticket needed — not among landed implementation proposals**; B06 released file | **HIGH (INFERRED) with large selections / LOW at start**: 3 transparent draws + 3 materials per selected id; ~1656 draws at 552 units (`P02:92-104`) | **MED**: ring count/materials/pulse must stay identical; `fx.stats["selection_rings"]` contract | New `.bak-<TICKET>` before edit; full-file restore |
| **P01-F1/F2 (GAP)** — dirty-flag Pass-2 transform writes + remove donor frame from batch key | `world3d_entities.gd` (+ `world3d.gd` for view_rect) | **No landed implementation proposal**; P11 explicitly defers it (`P11:71`); must not be bundled into P11's grant | **HIGH (INFERRED CPU)**: the #1 ranked per-frame hotspot — `O(N_instances)×2` per frame at start, dominated by static scenery (`P01:143-180`; `P03:174-177`) | **MED-HIGH**: touches teleport/rebind semantics and frozen-frame mesh; requires its own atom and capture | New ticket + fresh backup |
| **M03** — mill rotor to donor axle tip, drop camera billboard | `world3d_entities.gd` | P11 released; **M04 atom co-updated before landing** (`M03:326-344`); backup | **LOW perf (INFERRED)** — removes per-frame camera basis reconstruction; primary value is visual correctness (**no parity claim**: sail stand-in/spin sign remain PORT APPROX) | **HIGH visual**: fresh P0/real-map capture mandatory; old M04 checks 7/8/9 would go RED by design if not co-updated | Restore `inbox/backup/world3d_entities.gd.bak-M03` |
| **F2-03** — four touching field patches + reject-on-overlap | `game.gd` **and** `world3d_entities.gd` | P11 **and** M03 released; re-derive rotor clearance (`FIELD_QUAD_ROTOR_CLEAR_M=3.35` came from the *old* billboard sail projection, `F2-03:141`); F2-05 atom deltas authored; backups | **NONE/LOW perf (INFERRED)** — visual/gameplay fix, four fields instead of up to 49 | **HIGH**: `t_mill_logic` 6/6, `resow`, two files, RNG determinism, F2-05 Atom A thresholds written for 7×7; cross-variant sim hash divergence is by design | Restore `game.gd.bak-F2-03` + `world3d_entities.gd.bak-F2-03` |
| **F2-04** — mine magnetic-snap preview | `game.gd`, `world3d.gd` | B03 released `game.gd`; F2-03 not holding `game.gd`; P15 released `world3d.gd`; re-check against **now-landed** F2-02 (donor 1.5-cell snap vs port 4 m radius); backups | **LOW perf (INFERRED)** — one ≤9-cell spatial-hash query per ghost frame, no full `res_nodes` scan (`F2-04:289`) | **MED**: `t_mine_build`/`unified_mine_test`, ghost green/red verdict on snapped point; donor snap is mechanism-only, not parity | Restore `game.gd.bak-F204` + `world3d.gd.bak-F204` |
| **S02** — x8/x16/x32/x64 dropdown + cap 64 | `hud.gd`, `main.gd`, `t_hud_layout.gd` | P12 released `hud.gd`; P15 released `main.gd`; separate grant for the test file; decide §3.1 (with x8) vs §3.2 (without); three backups | **NONE / potentially NEGATIVE FPS (UNVERIFIED)** — a feature, not a perf fix; ×16+ means more sim steps within the 64-step cap (`S02:65-73`) | **MED-HIGH**: `t_hud_layout` exact speed-label/metadata constants must be updated as a *spec* (3 hunks), no UI overflow at 3 widths, fresh uitest; x16/x32/x64 are owner-directive PORT APPROX | Restore `.bak-S02` ×3 |
| **H07-a** — pass-order flip in `_assign_tileblocks()` | `game.gd` | B03/F2-03/F2-04 released; pinned-seed A/B protocol; backup | **NONE perf (INFERRED)** — visual-variation experiment, not a performance fix; changes `brng` consumption order and tileblock bytes (`H07:87-147`) | **HIGH visual**: BV32/BV128 movement indicators, season UV2 invariants, 29/29 + 17/17 + `assert_clean`; must revert if BV32 does not move | Restore `inbox/backup/game.gd.bak-H07` |

**Not candidates (closed):** B03 already landed (`game.gd`); B04 fully reverted
(`world3d_terrain.gd` clean); P02-A1 = P13-W3, P02-A3 = P14; P05's `textureSize` hoist
is LOW/negligible and line-number-fragile (`P05:237-253`) — do not trade B01/A06
streak fixes for ALU.

---

## 3. Explicit conflict resolution (claimants → single owner)

### 3.1 `world3d_entities.gd` — P11 vs M03 vs F2-03

All three proposals are still unapplied; the file is clean.

| Claimant | Ranges it edits | Overlap |
|---|---|---|
| P11 | `:114-117`, `:357-365`, `:381-383`, `:995-1020`, `:1436-1490`, `:1506-1509`, `:2327-2336` | none with rotor/field bodies, but shares file |
| M03 | `:262-278` (constants), `:1689-1720`, `:1772-1800`, `:2153-2188` (rotor loop + stats) | **direct textual overlap with F2-03 at `:266-273`** (same MILLFIX F2 comment/constant block) |
| F2-03 | `:266-273` (field constants), `:2190-2253` (field visual pass) | overlaps M03 constants; P11's `color` consumer at `:185-192` must keep `FIELD_SPAN_M` alias |

**Resolution:** **P11 → M03 → F2-03**, one at a time, never concurrently.
1. P11 first (no visual change; perf). Its stats hunk is additive; afterwards M03/F2-03
   must **re-derive** hunks (`git apply --recount --3way`, or re-read + re-derive), never
   hand-force. Take a fresh `.bak-M03` at the M03 handover.
2. M03 second, with M04's proposed atom corrected first. M03 explicitly protects the
   field region as byte-identical (`M03:147-148`), so F2-03 must come after it.
3. F2-03 last, **re-deriving the rotor clearance**: its `3.35 m` was derived from the
   old billboarded sail (`F2-03:141`); M03's fixed axle at local `+Z 1.8947 m` changes
   the ground projection. Re-check `inner = 7.2 − 3.65 = 3.55 m` against the new sail
   before applying; keep `FIELD_SPAN_M` as the alias so P11's `color` consumer survives.

### 3.2 `hud.gd` — P12 vs S02

- P12 ranges: `:89-94`, `:174`, `:218`, `:273`, `:1445-1523`, `:1611`, `:1667-1695`.
- S02 range: `:439-447` only. **No textual overlap**, but the charter grants **one
  owner per file** (`WAVE_G_CHARTER.md:154-155`), and S02's two added comment lines
  shift every later P12 hunk by +2 while P12's new members shift S02's context.

**Resolution:** **one owner holds `hud.gd` for the whole HUD window** and applies P12
first, then S02's hunk re-derived from the post-P12 bytes. `.bak-P12` must be taken
before P12; a **fresh `.bak-S02`** must be taken after P12 lands (S02 §4 explicitly
warns that its backup otherwise captures P12's bytes). `hud3d_adapter.gd` stays P12's
alone; S02 never touches it. S02's `main.gd` cap hunks are a separate file grant and
must follow P15's `main.gd` release; `t_hud_layout.gd` is a third, separate grant.

### 3.3 `world3d_terrain.gd` — P15 vs P16 vs B04

- **B04 is closed**: fully reverted, source byte-identical to `.bak-B04`, no `M` in
  git status (`B04_relief_impl.md:7,88-99`). It is not a live claimant.
- P15 and P16 **both** edit `_repack_mask_alpha()` (P15 B1 byte-swizzle + SHA cache;
  P16 Hunk B size-key cache) and `build()` (P15 B4 signature `build(p_async)`; P16
  Hunk D mesh-loop hoists). These are mutually incompatible as written.
- P16's diff was derived from a working tree that still carried B04's edits
  (`P16:31-35`); that state no longer exists, so its context is stale even before P15.

**Resolution:** **P15 takes the file first** (stronger startup win, complete async
chain). Grant one integrator `tile_atlas_loader.gd` + `world3d_terrain.gd` + `main.gd`
+ `world3d.gd` together so the required handoff (`P15:523-556`) cannot deadlock.
Then **P16 is optional**: re-derive only its non-overlapping hunks (C: `named_cells`
hoist; D/E: row hoists and dict aliases) against the post-P15 tree, **omit P16 Hunk B**
(superseded by P15 B1), and re-run the B04 visual invariants. If the post-P15 capture
shows any contour/face regression, stop and keep P15 alone.

### 3.4 `game.gd` — B03 (landed) vs F2-03 vs F2-04 vs H07

- B03 landed and released; its `_apply_detail_pass(brng)` call and P2 `tls_*` stamps
  are now in the file (`B03:83-113`).
- F2-03 `game.gd` ranges `:2492-2541`; F2-04 adds a helper at `:3094-3098` — disjoint
  text, but F2-03 §1 and F2-04 §5 both require serialised grants.
- H07's two hunks move `_apply_detail_pass(brng)` from before smoothing to after it —
  semantically coupled to B03's P1 `brng` draws and P2 stamps (`H07:87-92`).

**Resolution:** treat `game.gd` as a **serial queue**: B03 (done) → **F2-04** (small,
additive, test-safe, also releases `world3d.gd`) → **F2-03** (after `world3d_entities.gd`
is released by M03) → **H07-a** last and only as a pinned-seed visual A/B. If H07's
BV32 does not move, revert from `.bak-H07`; do not keep a visual-only change in a
performance tranche. At no time may two of these agents hold `game.gd`.

### 3.5 Other files (single claimant or closed)

| File | Owner for the integration window | Note |
|---|---|---|
| `water3d.gdshader` | P13 (W1/W2, then W3) | No other claimant. |
| `anim3d.gd` | P10 | No other claimant. |
| `hud3d_adapter.gd` | P12 | S02 explicitly excludes it. |
| `world3d_fog.gd` | P14 (new grant) | No current owner; project has no quad-count assertion. |
| `tile_atlas_loader.gd` | P15 integrator | B02 landed and released; keep B02 `.bak` untouched. |
| `main.gd` | P15 integrator, then S02 owner | P15 `:522-676`; S02 `:360/:721`; no textual overlap but one owner at a time. P09 §4.3's optional per-stage hook would also need `main.gd` — assign to the P15 integrator if added. |
| `world3d.gd` | P15 integrator (handoff), then F2-04 | P15 `:599/:639`; F2-04 `_sync_build_ghost` `:484-493`. |
| `variant3d/config_weak_gpu.json` | COORD (new file) | No source conflict; verify `user://options.json` does not override the three keys (`P08:152-153`). |

---

## 4. Ordered integration sequence (single-owner at every step)

`G04 done` below means: the gate log's selftest/render/P0/real-map evidence is
accepted **and** COORD has ruled on the stale-uitest 17/17 (§1). Each step ends by
filing hashes of the file and its backup; the next grant is issued only after that.

### Tranche T0 — prerequisites (no source edits)
1. Accept `G04_gate_log.md` evidence; record that uitest 17/17 is **stale/UNVERIFIED**.
2. Decide the uitest remedy (fresh run with the main watchdog raised past the observed
   138 s forced exit, or an explicit COORD waiver). Any HUD/speed/loader acceptance
   before this decision is not credible.
3. Freeze the P09 protocol and artifact dir; capture a **before** triplet on both 64²
   and real-map fixtures with the exact `p09-*-before-r1/2/3` ids (`P09:85-129`).
4. Issue written exclusive grants and record the file-lock table below.

### Tranche T1 — MINIMAL FIRST TRANCHE: best FPS-per-risk

| Step | Fix | Locked file(s) | Owner | Gate before release |
|---|---|---|---|---|
| 1 | **P13 W1+W2** (foam gate + `fract` drop) | `water3d.gdshader` | P13 | shader compiles; `t_terrain_shore` all checks; P0/real-map capture pixel-diff vs T0 before; `SCRIPT ERROR=0` |
| 2 | **P08 overlay** (3 display keys, `quality=high`) | *none* (new config only) | COORD | `--dump-config`; selftest 29/29, `t_smoke_fx` `cap>0`, minimap/P0/real-map unchanged; revert by deleting overlay |
| 3 | **P09 before/after triplet** for steps 1–2 | none | G04 | `Δp50`/`Δp95` of `wall_ms` move beyond run-to-run range in **both** fixtures; otherwise report `NO CHANGE / UNVERIFIED` and do not proceed on FPS grounds |

**Why these two first (INFERRED):** P13 is one unowned shader file, output-identical by
derivation on deep/waterline fragments, with the largest static fragment-count win
(`P05:45-54,255-284`); P08 touches **no source file at all**, is reversible by deleting
one JSON, and is gate-safe by construction (`P08:120-155,164-182`). Neither depends on
another owner releasing a file, and neither can produce a contested edit. W3 is
deliberately held back because P05 flags it "conditional; needs a capture before
merging" (`P05:286-299`).

### Tranche T2 — biggest structural win + safe disjoint CPU win
4. **P15 full chain** (loader worker mips → terrain async flags → main await/readiness →
   world3d handoff). Locks: `tile_atlas_loader.gd`, `world3d_terrain.gd`, `main.gd`,
   `world3d.gd` — **one integrator for all four**. Gates: G7–G12 of `P15:577-590`,
   byte-level atlas/mask honesty, window title-bar drag at "Loading art...", readiness
   assertion, and a **fresh** uitest. Expected benefit is startup responsiveness,
   **not** a steady-state FPS claim.
5. **P10** (anim cache). Locks `anim3d.gd` only — disjoint from step 4. Gate: byte-digest
   of `skin_vertices` on forced cache miss, `t_motion_capture`, `t_entities3d`,
   `donor_morph_pose_samples` unchanged.
6. **P13-W3** — same P13 owner resumes `water3d.gdshader` (no new handoff) only after the
   step-1 capture is reviewed and the `waveheight<=0.0` gate is confirmed intact.

### Tranche T3 — per-frame CPU/GPU trims (disjoint files, parallel-safe after grants)
7. **P12** — locks `hud.gd`, `hud3d_adapter.gd`. Requires the fresh-uitest decision from T0.
8. **P11** — locks `world3d_entities.gd`. Start of the three-way contest; grants for
   M03/F2-03 are **not** issued until P11's gates and hash record are filed.
9. **P14** — locks `world3d_fog.gd`. Independent of steps 7–8. With `FOG_OF_WAR=false`
   the expected start-frame delta is **zero [D]**; keep it only with a documented
   fog-on arm or defer it entirely (LOW FPS-per-risk).
10. **P16 subset (optional)** — may lock `world3d_terrain.gd` only after step 4's owner
    releases it; re-derive against post-P15 bytes, omit P16 Hunk B.

### Tranche T4 — visual/feature fixes, strictly serialised (not FPS work)
11. **M03** takes `world3d_entities.gd` (fresh `.bak-M03`); M04 atom co-updated first;
    fresh P0/real-map capture. Then releases the file.
12. **F2-03** takes `game.gd` + `world3d_entities.gd` (fresh backups both); re-derive
    rotor clearance; F2-05 Atom A deltas authored; `t_mill_logic`/`resow`/RNG gates.
13. **F2-04** takes `game.gd` + `world3d.gd` afterwards (fresh `.bak-F204` both);
    re-check against landed F2-02; mine build/preview gates.
14. **S02** takes `hud.gd` (re-derived after P12), `main.gd` (after P15), and
    `t_hud_layout.gd` (separate grant) as one coordinated owner; choose §3.1 vs §3.2.
15. **H07-a** takes `game.gd` last as a pinned-seed A/B; revert if BV32 does not move.

### Lock table (no step above violates it)

| File | T1 | T2 | T3 | T4 |
|---|---|---|---|---|
| `water3d.gdshader` | P13 (W1/W2) | P13 (W3) | — | — |
| config overlay | COORD | — | — | — |
| `tile_atlas_loader.gd` | — | P15 | — | — |
| `world3d_terrain.gd` | — | P15 | P16 (optional, after release) | — |
| `main.gd` | — | P15 | — | S02 (step 14) |
| `world3d.gd` | — | P15 | — | F2-04 (step 13) |
| `anim3d.gd` | — | P10 | — | — |
| `hud.gd` / `hud3d_adapter.gd` | — | — | P12 | S02 (step 14, rebase) |
| `world3d_entities.gd` | — | — | P11 | M03 → F2-03 |
| `world3d_fog.gd` | — | — | P14 | — |
| `game.gd` | — | — | — | F2-03 → F2-04 → H07 |

---

## 5. Acceptance and stop rules

- Re-run the full gate set after **each** tranche, not only at the end: selftest
  **29/29**, uitest **17/17 fresh**, `t_render_mode` PASS/`seam_missing=false`,
  `assert_clean` CLEAN, 2D `app/` untouched, windowed P0 + real-map non-blank with
  `full_width_dark_rows=0` and `SCRIPT ERROR=0` (`CHARTER.md:122-130`).
- Per-fix atoms: `t_terrain_shore` (P13), byte/pixel honesty + window drag (P15),
  `t_motion_capture` digest (P10), `t_hud_layout` 62 checks + `t_hud_fidelity` (P12),
  `t_entities3d`/`t_terrain_trees`/`t_motion_capture` (P11), `t_fog3d` (P14),
  M04 co-update (M03), `t_mill_logic`/resow/RNG (F2-03), mine build/preview (F2-04),
  speed-label spec + 3-width PNGs (S02), BV32 movement (H07).
- **Stop the whole integration** on any of: a failing gate, a `SCRIPT ERROR`, a new
  seam/dark row/black row, a changed `expected_pre_fix_failure`, or a donor-parity
  claim. Revert the whole tranche from its handover backups; do not hand-patch hunks
  to force green.
- FPS evidence is only admissible from the P09 protocol (§1). Before that, report
  `UNVERIFIED` for every tier in §2. Donor parity stays UNVERIFIED regardless of any
  gate result (`G04_gate_log.md:145-149`).

---

## 6. UNVERIFIED / open register for COORD

1. **No measured FPS, frame time, draw-call count, VRAM read or GPU timer exists.**
   All tiers in §2 are INFERRED static rankings.
2. **uitest 17/17 is stale**, not fresh; the watchdog forced exit and engine
   resource-leak warnings at 138 s are an open perf/teardown finding (`§1`).
3. P16's diff context is stale because B04 was reverted; re-derive or drop.
4. `world3d_entities.gd` three-way merge: P11/M03/F2-03 hunks are individually clean
   but each later owner must rebase; F2-03's rotor-clearance constant is derived from
   the pre-M03 billboard.
5. `Image.generate_mipmaps` thread-safety, `await` on dynamic calls, and upload timing
   for P15 are UNVERIFIED (`P15:599-604`); the window-drag test decides whether the
   HIGH startup tier is real.
6. P10's `_qmat_into` bit-identity and shared read-only pose safety are UNVERIFIED;
   the byte-digest check is mandatory before accepting its MED tier.
7. P14's expected start benefit is **zero by derivation**; its MED tier requires a
   fog-on arm that does not exist yet.
8. P02-A2 (selection rings) and P01-F1/F2 (dirty transforms / frame-key batch churn)
   are ranked HIGH but have **no landed implementation proposal**; they need new
   tickets and owners, and must not be smuggled into P11's grant.
9. F2-02's donor snap radius (1.5 map cells) differs from the port's 4 m; F2-04 must
   be re-checked against the now-landed donor truth (`F2_02:105`, `F2-04:298-302`).
10. H07 and S02 are not performance fixes; they are listed only so their file claims
    are serialised. H07's interaction with B03's `brng` consumption is UNVERIFIED.
11. No donor GPU A/B frame exists anywhere; every "looks like donor" statement in
    M03/F2-03/H07 remains INFERRED/UNVERIFIED.

*End of L04 report. Read-only; one report; no runner job, no source edit, no FPS claim,
no donor-parity claim.*
