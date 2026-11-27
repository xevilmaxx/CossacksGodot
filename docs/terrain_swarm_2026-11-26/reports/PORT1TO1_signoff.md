---
id: PORT1TO1-SIGNOFF-2026-11-27
title: "Final owner sign-off statement — full 1:1 Cossacks 3 donor port"
worker: SIGNOFF (read-only subagent; full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM__NO_APPROXIMATION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_signoff.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_signoff.md]
files_edited: []
scope_guard: "Repo file/line reads only. No source, shader, config, asset, test, fixture, result JSON, backup, queue, git, Godot job/gate/capture/ROI metric or donor execution by this worker. Exactly one repository file written: this report. Every fact is transcribed [O]/[D] from cited landed reports; no status, count, value, gate or reviewer line changed."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; 71 open [U]; no donor GPU A/B frame; no matched camera; no COORD ruling; 575/582/585 UNACKED."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
reviewer_line_sha256: 30FEC6929276B30830D397D525EA1AC43D11AF773B0CA263F0F04A16EA3928E7
---

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

# PORT1TO1 — final owner sign-off (2026-11-27)

This statement consolidates the landed governance set (`PORT1TO1_final_audit.md`, `PORT1TO1_handoff_vsync.md`, `PORT1TO1_parity_chain.md`, `PORT1TO1_owner_brief2.md`, `PORT1TO1_claim_recheck9.md`, `PORT1TO1_PLAN.md`). It re-adjudicates nothing, closes no `[U]`, promotes no value and claims no parity. Point-in-time at this read.

## 1. What is delivered

- **All implementation lanes DONE** in `variant3d/`: terrain/render, water/shore, objects/AAF/art, skirmish laws/rows, save contract, fog/camera/HUD, tools/host. Each is a **labelled** donor-text/donor-literal transplant (`[O]` bytes / `[D]` law) or telemetry — not a demonstrated donor-matching runtime value.
- **MCP host VERIFIED** — exactly 6 tools (`game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`), live 64×64 donor-backend QA probe; `game.tick({})` clean refusal. Parse checks 18/18 GDScript `--check-only`, V90 static 13/13 — static only.
- **Deterministic repeat: port-internal PASS** — `detcheck`/`detcheck2` (seed 20261113, 64 ticks / 2 frames, 1280×720) byte-identical per-frame `sha256_pixels`; chain condition 6 **PARTIAL, not CLOSED**. **ROI metrics 14/14 executed, 0 refusals, all `parity=UNVERIFIED`**, camera `NOT_SHARED_donor-oblique_vs_port-17p27`. Guard audits PASS.
- **Preserve-only mods intact** — 3 recorded witnesses byte-identical (`config_donor_capture.json` `aa857480…`, `main.gd.bak-COORD-I11` `3859b605…`, `world3d.gd.bak-COORD-I11` `44ee96c0…`); no flip/revert/repair/re-apply.
- **Final owner review: BLOCKED** (plan row 186), owner-gated on a matched donor GPU A/B frame + camera manifest. Canonical verdict line established; reviewer-line SHA recorded below.

## 2. What is explicitly NOT claimed

No donor parity (`parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`); no donor fidelity; no gate PASS; no tier above 2. No approximation adopted; no `[U]` closed; none of the nine P0 rows retired; no value promoted; no test/gate weakened. No donor binary opened/executed and no donor GPU A/B frame produced or compared. No COORD ruling exists. `RESULT IS GOOD` is admissible **only** when `blocking_unverified = []` and all six conditions hold — not today.

## 3. Exact `blocking_unverified` categories (non-empty ⇒ `RESULT IS NOT GOOD`)

- **No donor GPU A/B frame** exists and none may be produced under the read-only rule; the 12 H.264 stills are third-party, unknown build/camera/zoom/compression.
- **No matched camera** — `--camera NOT_SHARED_donor-oblique_vs_port-17p27`; FOV `17.27°` is PORT APPROXIMATION; V1/V2 remain `[U]`.
- **Nine P0 rows OPEN** — P0-1 (water U12), P0-1b (water U4*), P0-2 (water U1/U3/U5/U6), P0-3 (FOW grid), P0-4 (tick interleave), P0-5 (animation blend), P0-6 (save container), P0-7 (RNG G1), P0-8 (selection/projection). `CLOSED` appears for no row.
- **575/582/585 UNACKED** (owner-only) — no result JSON, `assert_clean` last read DIRTY; gates not green; D1/D3 unruled.
- **No COORD ruling** — condition 6 requires a COORD-signed zero-mismatch geometry+frame ruling; none exists.
- Additional residuals: **71 open `[U]`** (A42/B14/C5/D10, incl. D4 `[U]`); full list at `owner_brief2.md:93-96`. **Six-condition chain 0/6 CLOSED** — conditions 2 and 6 PARTIAL (port-internal only), 1/3/4/5 BLOCKED.

## 4. Required owner actions to change status

Only COORD/the owner can supply these; no further worker action can. `RESULT IS NOT GOOD` stands until all hold and `blocking_unverified = []`:

1. Produce a genuine same-size/seed/type/season/**matched-camera** donor **GPU frame** from owner-launched `cossacks.exe` (Route A) + written key/camera/ROI manifest.
2. Supply an admissible non-blank 1280×720 port capture, `script_error_lines=0`, pinned seed/camera/size at the matched ROI.
3. Record matched, labelled inputs (same keys, or importer-rendered same geometry).
4. Run fresh, non-advisory gates with D1/D3 ruling, `app/**` byte-identical, and **575/582/585 acknowledged with evidence-backed reasons**.
5. Complete spec/toolchain evidence (root `manifest.json`, atlas built/bound, Objects feed wired, N17 populated and signed) with `blocking_unverified = []`.
6. Issue a **COORD-signed** ruling of demonstrated geometry-byte equality and pixel-identical frame at zero mismatch, and retire all nine P0 rows via their own zero-mismatch experiments.

Until then the honest ceiling is "gates green / internal consistency PASS / donor parity UNVERIFIED".

## 5. Canonical verdict line — verbatim

**Mandatory reviewer line** (SHA-256, UTF-8, 167 B, no trailing newline: `30FEC6929276B30830D397D525EA1AC43D11AF773B0CA263F0F04A16EA3928E7`; `handoff_vsync.md:16/20/46`, `final_audit.md:16/31/88`):

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

**Canonical minimal verdict line** (`verdict_sync.md:221`, canonized at `handoff_vsync.md:31`, carried at `final_audit.md:85`):

```
RESULT IS NOT GOOD — blocking_unverified is non-empty; parity.status=UNVERIFIED; parity.claim=NONE; no donor GPU A/B frame exists and none may be produced under the read-only rule; static [D] facts only narrow experiments; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximations; no parity claim.
```

`visual_parity_claim = false` is an appendable additive guard. All 78 frontmatter verdict strings and 10 fenced blocks differ only by additive qualifiers; no substantive claim exists (`verdict_sync §5-6`, `handoff_vsync §1-3`).

---

*End of PORT1TO1-SIGNOFF. Exactly one repository file written by this worker (`docs/terrain_swarm_2026-11-26/reports/PORT1TO1_signoff.md`). No code, Godot, git or donor execution; no approximation; no parity claim. `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
