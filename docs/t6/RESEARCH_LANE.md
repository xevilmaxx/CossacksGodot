# T6 RESEARCH LANE — parent state (T6-RESEARCH)

**Owner:** T6-RESEARCH (recursive-swarm lane parent). **Updated:** 2026-11-23.
**Scope:** read-only on everything except this lane's owned outputs:
`docs/research/T6_S0*.md`, `docs/t6/RESEARCH_LANE.md`, `docs/t6/reports/T6-S*.md`.
No Godot jobs (ZERO runner tickets). No donor assets copied into the repo.

## Tooling constraint (important, record once)

The task specification says to spawn five micro-workers with a `subagent` tool
(`agent:"general"`, `model:"opencode/hy4-flash-free"`) and follow up by `sessionID`.
**That tool is not exposed in this harness.** Discovery via Code Mode `search`
(`subagent`, `session prompt`, `create session`, `task delegate`) returned no
agent-spawning tool; the only `opencode.*` tools available are `models`,
`list_mcp_resources`, `read_mcp_resource`, `session_move`, `session_rename`,
`worktree_*`. Therefore the parent executed all five work-items directly under
its own owned output paths. No child `sessionID` exists; the `sessionID` column
below is `N/A (no subagent tool)`. Escalation model was likewise unavailable
and was not needed — all five tickets were completed in this session.

## Ticket state

| ID | Question / output doc | sessionID | State | Key findings (brief) |
|---|---|---|---|---|
| T6-S01 | Projection branch + heightfield resolution → `docs/research/T6_S01_camera.md` | N/A (direct) | **DONE** | Main world view = `glFrustum` perspective: renderer byte `+0xC8==0` set by default constructor (`FUN_008127d8`); orthographic `==1` only via alternate setter; `gluPerspective` 0 xrefs. Corrected baseline's mode 2/3/4 table. Heightfield = square map grid 256²/320²/480²/640² by skirmish size setting (`miscext2.script:19-26,45`); port fixed 160² is 1.6–4× coarser. Mesh LOD UNVERIFIED. Evidence ids in doc. |
| T6-S02 | Water sampler→texture-unit bindings → `docs/research/T6_S02_water_bindings.md` | N/A (direct) | **DONE** | Literal bindings statically UNRECOVERABLE: sampler names absent from `cossacks.exe`; NO shader/uniform API imported, `wglGetProcAddress` present ⇒ dynamic resolution. Functional identities: `waveMap`=DiffuseWaves0 (256²), `hmapTex`=engine terrain height (alpha), `reflectionMap`=projected texture (provenance UNVERIFIED), shadowMap=engine shadow map. No unit numbers may be asserted. |
| T6-S03 | All 22 smoothing chains vs port's 10 → `docs/research/T6_S03_smooth_chains.md` | N/A (direct) | **DONE** | Full 22-chain transcription with line numbers. Port `smooth_summer.json` is an **exact 141-entry** copy of C00–C09 (0 mismatches). Missing: 10 Winter chains C11–C20 (lines 934–1810) + 2 empty terminators (C10/C21). Winter chains are **exact structural mirrors** of Summer under `_winter` suffix. **Cross-lane: TERRAIN T14 (winter_variant) should consume the C11–C20 mirror finding.** |
| T6-S04 | Web gaps vs mechanics.json → `docs/research/T6_S04_web.md` | `ses_t6s04web20261123` (2 failed spawns) → solo fallback | **DONE** | 7 genuine gaps with URLs: gold-shortage desertion/ship-stop, iron+coal stop-firing, military research rows, national unit stat deltas, naval classes/upkeep, production-building siege rule, mass-army scale. In-house OpenGL engine + community .oss/.osm/.aaf tooling corroborate our binary/format audits. Wiki facts already in mechanics.json explicitly excluded. Report `docs/t6/reports/T6-S04.md`. |
| T6-S05 | Per-action animation truth → `docs/research/T6_S05_anim_truth.md` | `ses_t6s05anim20261123` (child, `opencode-go/hy4-flash-free`) | **DONE** | Child re-derived all data with an independent parser (`int.from_bytes` + raw-line AAF + `os.listdir`) — full agreement. All 5 families fps=30; exact donor action ranges/durations, sampled-frame lists, port deltas tabulated. **Only 1 duration divergence:** `peasant.walk` 0.667 donor → **1.08 port, a deliberate stride fix — DO NOT REVERT**; other 4 families 100% donor-exact. Coverage gaps: unbaked actions 4/14/5/1/4 and unbaked `dragoon18_horse.oss` (484,992 B) mount (rider-only bake; `tool=null` is correct). Report `docs/t6/reports/T6-S05.md`. **Cross-lane: UNITS T6-U01/T6-U04 should consume R1–R3 (do not revert 1.08; mount needs its own integration ticket).** |

Reports (per-worker claim tables): `docs/t6/reports/T6-S01.md` … `T6-S05.md`.

## Supervision log

- 2026-11-23: read baselines (SWARM_OPS §5a/§5b/§7, T6_WAVE_PLAN LANE RESEARCH,
  AGENT_PROTOCOL, RENDER_ARCH_CAMERA/CRAFT_ANYTHING/SHADERS/REFLECTION,
  WATER_REPORT, TERRAIN_BLEND_DONOR_PLAN, DC_FORMATS, UNIT_BAKING_FIX).
  Discovered no `subagent` tool; switched to direct execution. Lane doc created.
- 2026-11-23 — COORDINATOR BROADCAST ACKNOWLEDGED (owner directive, re-read
  SWARM_OPS.md §7.2 lines 213–243): new/replacement children prefer
  `opencode-go/hy4-flash-free` (the `opencode/hy4-flash-free` pool is
  quota-blocked); escalation remains `opencode-go/muse-spark-1.3-contributor#high`
  after 2 failures or >20 min silence. §7.2 now documents that the `subagent`
  tool is NOT available inside child sessions (confirming this lane's finding)
  and that lane parents spawn via background
  `opencode run --agent general --model <ref> --session <id> --title <t> --auto <prompt>`
  with the prompt passed positionally from a file, plus follow-ups on the same
  session id. Host facts: Python = `python` (3.14), NEVER `python3` (MS-Store
  alias trap); Blender = `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`
  (not on PATH). **This lane spawned ZERO children**, so no child used the
  quota-blocked pool and there is no failed attempt to re-spawn. All five
  work-items were already executed directly by the parent (evidence gathering
  complete for all five); the CLI spawn path is recorded for any future
  replacement work but was not used, to avoid duplicating in-flight research.
  Host facts honoured: all analysis used `python`, no Blender jobs.
- 2026-11-23 — COORDINATOR CHECK-IN: S01–S03 verified on disk and accepted as
  direct-execution fallback; lane table updated to DONE with evidence paths.
  Cross-lane routing noted: **T6-S03's Winter-mirror finding is for TERRAIN T14
  (`winter_variant`)** — the coordinator can route `docs/research/T6_S03_smooth_chains.md`
  §3/§4.3 to that lane. For S04/S05 the coordinator directed an attempt to
  spawn one CLI child each (`opencode run --agent general --model
  opencode-go/hy4-flash-free --session <id> --title <t> --auto <prompt-from-file>`,
  background shell job); solo execution only after 2 failed spawns. Prompts
  include project root, donor path, single owned output doc, read list, exact
  question, evidence labels/citations, read-only boundary and the host facts
  (`python` 3.14 not `python3`; Blender at `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`).
- 2026-11-23 — CLI spawn attempts (per directive):
  * Attempt 1 S04 `t6-s04-web-20261123` and S05 `t6-s05-anim-20261123`:
    **FAILED** — OpenCode CLI rejects session ids not starting with `ses`
    (S05 error `Expected a string starting with "ses"`; S04 printed help).
  * Attempt 2 S04 `ses_t6s04web20261123`, S05 `ses_t6s05anim20261123`, both on
    `opencode-go/hy4-flash-free` with prompt files under
    `%TEMP%\opencode\t6_S0{4,5}_prompt.txt`, logs `t6_s0{4,5}_child.log`:
    S04 again printed help (argument-parse failure) = **2 failures** ⇒ solo
    fallback executed by parent; `docs/research/T6_S04_web.md` and
    `docs/t6/reports/T6-S04.md` landed. S05 retry still running at the time of
    this entry; its result will be checked on notification.
  * No quota error was observed on `opencode-go/hy4-flash-free`; the failures
    were CLI session-id/argument parsing, not model quota.
- 2026-11-23 — S05 child `ses_t6s05anim20261123` completed; parent read both
  output files (§7.3 "check outputs, not promises") and verified: 438-line
  research doc with §1–§7, 13-claim table and boundaries; 47-line worker report
  with all 12 acceptance criteria PASS. Independent second parser agreed with
  the parent's data on every header/action/duration/sample value and added byte
  hex, AAF line numbers, sampled-frame lists, identical-range pairs and the
  `dragoon18_horse` mount. Ticket marked DONE. Cross-lane routing noted:
  **UNITS T6-U01/T6-U04** for the 1.08 stride fix (do not revert), unbaked
  action coverage and the cavalry-mount gap.
- 2026-11-23 — ALL FIVE T6 RESEARCH TICKETS LANDED. Parent performed final
  boundary check: only `docs/research/T6_S0{1..5}_*.md`,
  `docs/t6/reports/T6-S0{1..5}.md` and `docs/t6/RESEARCH_LANE.md` were written
  by this lane; no `app/**`, `rustport/**`, SWARM_BOARD/OPS/AGENT_PROTOCOL or
  other lane's doc was edited; no donor asset copied; no Godot/Blender job.
