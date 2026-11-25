---
title: CLEAN-01 — resolve variant runner historical unacknowledged failures
area: variant3d / queue hygiene
owner: CLEAN-01 queue-hygiene micro-worker
date: 2026-11-25
scope: historical variant results with ticket < 312 only; never running/pending
status: NOT CLEAN — history hygiene resolved, formal verdict blocked
verdict_detail: "0 unacked failure-status jobs on variant spool; tool reports DIRTY from live current job; gate tool mis-wired to app spool"
---

# CLEAN-01 — variant queue historical failures

## 1. Scope, method, honesty rules

- Read `docs/variant3d/STATUS_WAVE7_PHASE2.md` (qualifications), `docs/COMMANDS.md`
  (runner/clean-gate rules), `variant3d/tools/assert_clean.py`,
  `variant3d/tools/godot_runner.py:cmd_ack` (538-564),
  `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_05_shipping.md` (COMP-05 measurement).
- Snapshot BEFORE any ack written to `inbox/backup/godot_queue_status_backup.md`.
- Ack scope: historical result JSONs with **ticket < 312**, via
  `python variant3d\tools\godot_runner.py ack <ticket> --reason "<reason>"`.
  `cmd_ack` sets `acknowledged` / `ack_reason` / `ack_at` on the result JSON and syncs
  the same three fields into the matching `status.json` history entry. No result was
  deleted; no job ≥ 312, running or pending was touched; no reset was performed.
- Superseding PASS jobs were required to be **observed `ok` in
  `variant3d/.godot_queue/status.json`** and **documented in a prior report** (V70,
  V711, V714, V715, V732-V737, V752, V760-V768, V770-V774, V777-V792, FIXSEL,
  FIXTERRAIN, FIXCOLOR, FIXMOVE, TERRAIN_SMALL, MILLFIX, COMPLETENESS_01/04/05/06).
  All 73 distinct superseding tickets used below were verified `ok` before acking.

### Critical tool finding (do not silently drop)

`variant3d/tools/assert_clean.py:34` sets
`SPOOL = ROOT / "app" / ".godot_queue"`. The variant copy therefore checks the **2D app
spool** (`history total 254`, `acknowledged 9`), not `variant3d/.godot_queue`.
`app/tools/assert_clean.py:34` is identical. This was already flagged independently by
`COMPLETENESS_06_verdict.md:42` ("variant-aware clean gate unresolved") and
`COMPLETENESS_05_shipping.md:107`. Its CLEAN/DIRTY verdict is **not**, by itself, a
variant clean verdict; the variant spool was checked separately by direct file read
(§5). No tool file was edited (out of scope).

## 2. Initial tool output (verbatim, BEFORE acks)

`python variant3d\tools\godot_runner.py status`:

```text
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 398
next_ticket = 401
pending      = 3 [398, 399, 400]
godot.lock   = HELD (age 9.3s)
completed    = 397
max wait     = 503.08s   mean wait = 46.73s
max run      = 605.56s
statuses     = {'failed': 127, 'ok': 248, 'timed-out': 22}
```

`python variant3d\tools\assert_clean.py --json` (exit 0; note: reads the **app** spool):

```json
{
  "clean": true,
  "verdict": "CLEAN",
  "reasons": [],
  "checks": {
    "processes": { "clean": true, "count": 0, "details": [] },
    "lock": { "clean": true, "exists": false, "state": "free", "age_sec": null, "max_age_sec": 300.0 },
    "history": { "clean": true, "enabled": true, "total": 254, "acknowledged": 9, "failures": [] }
  }
}
```

Pre-ack variant spool (direct `status.json` read): 398 history entries;
`ok 249 / failed 127 / timed-out 22 / error 0 / skipped 0`; **22 unacked failure-status
jobs (all timed-out, all ticket < 312)**; 127 unacked `failed` (78 with ticket < 312);
0 acked. This already exceeds the stale COMP-05/STATUS figures of 19 timed-out and ~84
non-ok because the swarm kept submitting jobs (tickets 258-397).

## 3. Ack table (ticket | id | failure | superseding job | reason | acked?)

Reasons are condensed; the full `ack_reason` string is stored on each result JSON.
"Superseding job" is the ticket whose status was verified `ok` and whose PASS is cited
in the named report. All rows are ticket < 312.

| Ticket | id | Failure | Superseding PASS job | Reason (why it was a probe iteration) | Acked? |
|---:|---|---|---|---|---|
| 0 | v70-baseline-selftest | failed | 4 / 5 | fresh project lacked C3* class cache; bootstrap 4 + baseline 5 29/29 (V70) | YES |
| 1 | v70-import-bootstrap | failed | 4 | import killed by concurrent 2D doctor taskkill; clean re-run 4 (V70) | YES |
| 2 | v70-baseline-selftest-r2 | failed | 5 | same class-cache failure r2; baseline 5 29/29 (V70) | YES |
| 3 | v70-import-bootstrap-r2 | failed | 4 | same concurrent import interference r2; re-run 4 (V70) | YES |
| 7 | v732-camera3d | failed | 24 | intentional MODULE_MISSING before camera3d landed; parse 24 (V732/V711) | YES |
| 8 | v718-anim3d-check | failed | 19 | anim3d parse errors fixed; parse 19 ok (V718) | YES |
| 9 | v734-entities3d | failed | 49 | intentional MODULE_MISSING before entities module; test 49 8/8 (V734/V714) | YES |
| 10 | v736-t-fog3d | failed | 23 | t_fog3d test-side parse error, not module; test 23 9/9 (V736) | YES |
| 14 | v711-camera-parse | failed | 24 | deg2rad / unproject_position parse errors fixed; parse 24 (V711) | YES |
| 15 | v733-t-pick3d | failed | 127 | all MODULE_MISSING before picking3d; probe 127 6/6 (V733/COMP-01/V768) | YES |
| 16 | v714-probe | timed-out | 41 | temp probe stdout only banner, quit never reached; runtime 41 + parse 30 ok (V714) | YES |
| 17 | v735-fx3d | timed-out | 44 | test guard called nonexistent Script.is_valid() and hung; final 44 13/13 (V735) | YES |
| 18 | v737-render-mode-seam-r1 | failed | 256 | probe before integration seams; final t_render_mode 256 10/10 (STATUS/V737) | YES |
| 21 | v715-parse | timed-out | 31 | fx parse errors then hung after scr.new() error; parse 31 ok (V715) | YES |
| 29 | v735-fx3d-r2 | timed-out | 44 | same is_valid() guard hang on r2; final 44 13/13 (V735) | YES |
| 33 | v735-fx3d-r3 | failed | 39 | lifetime check failed on queue_free flush; deterministic signals 39/44 (V735) | YES |
| 37 | v735-fx3d-final | failed | 39 | same deferred-delete flush failure; deterministic signals 39 13/13 (V735) | YES |
| 40 | v735-fx3d-missing | failed | 44 | OS.has_environment_variable test bug; fixed, 44 13/13 (V735) | YES |
| 43 | v735-fx3d-missing2 | failed | 44 | intentional FAIL MODULE_MISSING probe; real test 44 13/13 (V735) | YES |
| 46 | v714-entities-test | failed | 49 | exposed 3 integration bugs, all fixed; test 49 8/8 (V714) | YES |
| 47 | v714-entities-test2 | failed | 49 | same integration defects before fix; test 49 8/8 (V714) | YES |
| 48 | v714-entities-test3 | failed | 49 | same integration defects before fix; test 49 8/8 (V714) | YES |
| 53 | v750-baseline-render-mode | failed | 67 | probe before integration landed; render-mode 67 ok, final 256 (V750) | YES |
| 56 | v7-52-input-integration-parse | failed | 58 | Cannot infer type errors from relaxed world typing fixed; parse 58/66 (V752) | YES |
| 62 | v7-52-input-uitest | timed-out | 191 | hung on concurrent main.gd:1344 parse error, no verdict; final uitest 191 17/17 (V752) | YES |
| 69 | v-launcher-config3d-selftest | failed | 254 | wall-clock/queue contention, not game crash; final gate 254 29/29 (COMP-04 E15) | YES |
| 73 | audit3d-shot-windowed | failed | 253 | blocked by other agents' in-flight parse errors; real capture 253/289 (COMP-04) | YES |
| 81 | v760-light-probe | failed | 90 | temp light-rig probe harness bug; probe 90 19/19 (V760) | YES |
| 84 | v760-light-probe2 | failed | 90 | same harness bug on retry; probe 90 19/19 (V760) | YES |
| 89 | v762-probe-before | timed-out | 118 | concurrent V7-65 parse error hung probe; fixed, probe 118/126 ok (V762) | YES |
| 93 | v769-check-self-base-before | failed | 111 | expected MISMATCH on stale artifact; restored snapshot check 111 ok (V769) | YES |
| 95 | v768-pick-probe | failed | 127 | probe-side parse error (empty inner class); final probe 127 6/6 (V768) | YES |
| 96 | v766-jump-probe | failed | 114 | camera not settled in tree in _initialize; deferred probe 114 11/11 (V766) | YES |
| 99 | v766-t-camera3d | failed | 238 | t_camera3d tree-timing artifact 8/14; corrected probe 238 8/8 (V790/COMP-04 E7) | YES |
| 103 | v768-pick-probe-r2 | timed-out | 127 | probe-side null get_viewport() aborted quit; final probe 127 6/6 (V768) | YES |
| 105 | v765-probe | timed-out | 116 | first tint probe found MultiMesh defect then hung; probe 116 21/21 (V765) | YES |
| 106 | v766-jump-probe2 | failed | 114 | probe used out-of-map coords, clamp rejected; probe 114 11/11 (V766) | YES |
| 107 | v771-audio-probe | timed-out | 117 | work in _initialize before tree notifications, quit missed; deferred 117 6/6 (V771) | YES |
| 108 | v770-shot-windowed | failed | 253 | windowed shot failed under queue contention; real capture 253 (COMP-04 E15) | YES |
| 119 | v768-pick-probe-r4 | failed | 127 | probe hardcoded 1280x720 cursor vs 64x64 headless viewport; 127 6/6 (V768) | YES |
| 123 | v770-shot-windowed-diag | failed | 253 | diagnostic shot under contention; real capture 253 (COMP-04) | YES |
| 124 | v768-pick-probe-dbg | failed | 127 | diagnostic confirmed 64x64 viewport cause; fixed, 127 6/6 (V768) | YES |
| 125 | v762-probe-after2 | failed | 126 | probe-only get_viewport() on SceneTree; fixed to root.get_viewport(), 126/128 ok | YES |
| 132 | v770-shot-windowed-diag2 | failed | 253 | diag2 shot under contention; real capture 253 (COMP-04) | YES |
| 139 | v774-probe | failed | 161 | strict bind/donor index match rejected morph; probe 161 20/20 (V774) | YES |
| 142 | v774-probe2 | failed | 161 | same morph-match defect; probe 161 20/20 (V774) | YES |
| 146 | v774-probe3 | failed | 161 | same morph-match defect; probe 161 20/20 (V774) | YES |
| 150 | v774-parse2 | failed | 154 | parse probe during topology rewrite; parse 154 + probe 161 20/20 (V774) | YES |
| 156 | v774-probe4 | failed | 161 | generate_normals() absent in Godot 4.7; computed normals, 161 20/20 (V774) | YES |
| 159 | v774-probe5 | failed | 161 | stats Dictionary read by reference; code path passed, 161 20/20 (V774) | YES |
| 160 | v774-probe-final | failed | 161 | same stats-by-reference probe assertion; 161 20/20 (V774) | YES |
| 166 | v770-journey3d | failed | 254 | anim3d wrong base + watchdog; fixed, final gate 254/256 (COMP-04 E12/E15) | YES |
| 167 | v777-zoom-anchor-probe | timed-out | 174 | unhandled String() cast, quit never reached; final probe 174 12/12 (V777) | YES |
| 168 | v770-journey3d-long | failed | 254 | long journey watchdog/queue contention; final gate 254/255 (COMP-04 E15) | YES |
| 170 | v777-zoom-anchor-probe-r2 | failed | 174 | probe assertion geometrically false; final probe 174 12/12 (V777) | YES |
| 173 | v770-journey3d-probe | failed | 256 | probe parse error from wrong base; fixed, final 254/256 (COMP-04 E12) | YES |
| 175 | v770-journey2d-probe | failed | 254 | 2D journey probe under contention; final gate 254/255 (COMP-04 E15) | YES |
| 178 | v778-auto-skin-probe | timed-out | 180 | skin_info verts/frames1 bug aborted _initialize; corrected 180/181 24/24 (V778) | YES |
| 188 | perf3d-sync-probe2 | failed | 197 | pre-fix sync probe; hot path optimized, probe 197 11/11 (V780) | YES |
| 189 | perf3d-sync-probe3 | failed | 197 | same pre-fix sync probe; probe 197 11/11 + selftest 198 (V780) | YES |
| 194 | v779-probe-before | failed | 199 | pose-memo probe before fix; 8.18-11.91x PASS 199/200 (V779) | YES |
| 206 | v781-probe-before | failed | 211 | failed BY DESIGN (2/8 reproduces bug); fix verified 211 11/11 (V781) | YES |
| 215 | v782-parse-terrain | timed-out | 242 | extra -- separator + contention; corrected argv parse 242 ok (V782 §5) | YES |
| 218 | v782-parse-terrain-retry | timed-out | 242 | same extra -- separator hang; corrected argv 242 (V782 §5) | YES |
| 219 | v786-tileindex-shader-probe | failed | 235 | shader probe GDScript Variant inference error; final 235 47/47 (V786) | YES |
| 221 | v782-parse-terrain-order | timed-out | 242 | argv-order hang from extra --; corrected argv 242 (V782 §5) | YES |
| 223 | v786-tileindex-shader-probe-v2 | timed-out | 235 | invalid sampler hint then null-conversion hang; final 235 47/47 (V786) | YES |
| 225 | v782-enum-probe | timed-out | 242 | enum probe hang from extra --; V782 §5 lists 225 among early attempts, 242 ok | YES |
| 226 | v786-tileindex-shader-probe-v3 | failed | 235 | non-const uniform default error; fixed, final 235 47/47 (V786) | YES |
| 227 | v782-parse-water-control | timed-out | 222 | water-control parse hang from extra --; corrected parse 222 ok (V782/V784) | YES |
| 228 | v786-tileindex-shader-probe-v4 | failed | 235 | wrong get_shader_parameter default assertions; final 235 47/47 (V786) | YES |
| 230 | v791-dual-mode | timed-out | 245 | GDScript parse errors kept SceneTree alive until kill; both modes 245 28/28 (V791) | YES |
| 231 | v790-probe | failed | 238 | probe harness: reused key, out-of-map jump target; corrected 238 8/8 (V790) | YES |
| 232 | v786-tileindex-shader-probe-v5 | failed | 235 | uniform dict has no default_value; source-literal checks 235 47/47 (V786) | YES |
| 233 | v782-parse-terrain-final | failed | 242 | extra -- separator hid --check-only; corrected argv 242 (V782 §5) | YES |
| 234 | v782-selftest | failed | 243 | selftest failed from argv/order contention; rerun 243 29/29 (V782 §5) | YES |
| 236 | v790-probe2 | failed | 238 | same wrong jump target / too-tight tolerance; corrected 238 8/8 (V790) | YES |
| 237 | v782-parse-terrain-r2 | timed-out | 242 | same extra -- separator hang; corrected argv 242 (V782 §5) | YES |
| 239 | v791-dual-mode | failed | 245 | array mode failed 20/26 pre-fix; both modes 245 28/28 (V791) | YES |
| 240 | v790-uitest | failed | 255 | stale artifact under queue contention, no verdict; final uitest 255 17/17 (V790) | YES |
| 244 | v791-dual-mode | failed | 245 | array str(null) bug 23/28; both modes 245 28/28 (V791) | YES |
| 246 | v792-parse-terrain | failed | 247 | nonexistent PackedByteArray.to_byte_array(); fixed, parse 247 ok (V792) | YES |
| 248 | v791-triple-mode | failed | 250 | Vector2 vs Vector2i probe parse error; probe 250 24/24 (V791) | YES |
| 249 | v792-integration-probe | failed | 251 | stub C3Game.map_w not assignable; StubGame, 251 20/20 (V792) | YES |
| 260 | fixsel-before-probe | timed-out | 279 | work in _initialize with camera out of tree, quit skipped; deferred 279 10/10 (FIXSEL) | YES |
| 264 | fixterrain-probe | failed | 293 | probe assertion / float() bug; fixed, 293 20/20 (FIXTERRAIN §7) | YES |
| 266 | fixsel-before-probe-r2 | failed | 279 | 1/6 measured BEFORE state, not regression; after 279 10/10 (FIXSEL) | YES |
| 267 | fixselvis-probe | failed | 273 | queue_free rings deferred a frame; deferred probe 273 13/13 (FIXSEL_visuals) | YES |
| 269 | fixterrain-after | failed | 289 | blocked by other agents' in-flight parse errors; capture 289 ok (FIXTERRAIN §7) | YES |
| 271 | fixcolor-parse1 | failed | 295 | PackedByteArray.subarray() absent in Godot 4.7; parse 295 ok (FIXCOLOR) | YES |
| 275 | fixterrain-depcheck | failed | 288 | parse/assertion during in-flight edits; parse 288 + probe 293 (FIXTERRAIN) | YES |
| 287 | fixterrain-probe-final | timed-out | 293 | probe float()/assertion bug then timeout; fixed, 293 20/20 (FIXTERRAIN §7) | YES |
| 292 | fixterrain-probe-shadow | timed-out | 293 | shadow probe bug then timeout; fixed, 293 20/20 / 291 ok (FIXTERRAIN §7) | YES |
| 296 | play2fix-navbox-probe-before | failed | NONE | INVALID baseline (bind before tree); no PASS supersede, FAST-LANE skipped selftest | **NO** |
| 297 | fixcolor-probe | failed | 298 | probe used nonexistent Basis.xform(); fixed, 298 17/17 (FIXCOLOR) | YES |
| 300 | play2fix-navbox-probe-after | failed | NONE | valid measurement with y-centre −3 tiles; no PASS supersede, FAST-LANE | **NO** |
| 301 | smallmap-probe-64 | failed | 307 | literal %20 in config path, no script fault; probe 307 21/21 (TERRAIN_SMALL) | YES |
| 302 | smallmap-probe-64-r2 | failed | 307 | inspected in _initialize before _ready; deferred probe 307 21/21 (TERRAIN_SMALL) | YES |
| 306 | smallmap-probe-64-r3 | failed | 307 | split _run_checks locals parse error; fixed, 307 21/21 (TERRAIN_SMALL) | YES |
| 309 | millfix-probe | failed | 310 | probe-only use_colors order + .ctex fallback; probe 310 20/20 (MILLFIX) | YES |

**Ack totals:** 100 historical unacked non-ok jobs with ticket < 312 enumerated
(22 timed-out + 78 failed); **98 acked** with a documented superseding PASS job;
**2 deliberately left unacked** (296, 300). All 22 gate-relevant `timed-out` jobs were
acked, which is the condition COMP-05 F-02 required for the clean-gate history check.

## 4. Final tool output (verbatim, AFTER acks)

`python variant3d\tools\godot_runner.py status`:

```text
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 408
next_ticket = 414
pending      = 6 [408, 409, 410, 411, 412, 413]
godot.lock   = HELD (age 50.5s)
completed    = 407
max wait     = 503.08s   mean wait = 49.44s
max run      = 605.56s
statuses     = {'failed': 130, 'ok': 255, 'timed-out': 22}
```

`python variant3d\tools\assert_clean.py --json` (exit **1**):

```json
{
  "clean": false,
  "verdict": "DIRTY",
  "reasons": [
    "1 Godot process(es) alive"
  ],
  "checks": {
    "processes": {
      "clean": false,
      "count": 1,
      "details": [
        {
          "pid": 4508,
          "name": "Godot_v4.7.2-stable_win64.exe",
          "command": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Microsoft\\WinGet\\Links\\godot.EXE --path variant3d --script res://tests/t_motion_capture.gd -- --config res://tests/fixtures/small_map_64.json --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa/unused_flag.png --timeout 280"
        }
      ]
    },
    "lock": { "clean": true, "exists": false, "state": "free", "age_sec": null, "max_age_sec": 300.0 },
    "history": { "clean": true, "enabled": true, "total": 254, "acknowledged": 9, "failures": [] }
  }
}
```

The live PID 4508 is a **current** variant job (`--path variant3d`, ticket ≥ 312; the
queue is churning — `next_ticket` moved 401 → 414 during this worker's run). It is out
of scope; no process was killed and no job was cancelled. Per
`variant3d/tools/CLEAN_GATE.md:100-103`, a meaningful gate verdict requires a quiet
queue (no pending jobs, no live Godot process), which does not hold here.

## 5. Independent variant-spool check (direct `status.json` read, after acks)

| Check | Result |
|---|---|
| `variant3d/.godot_queue/status.json` history entries | 407 |
| status counts | `ok 255 / failed 130 / timed-out 22 / error 0 / skipped 0` |
| acknowledged entries | **98** (all historical, ticket < 312) |
| unacked failure-status (`timed-out`/`error`/`skipped`) | **0** |
| unacked `failed` with ticket < 312 | 2 (296, 300) — excluded from the gate by D-13 |
| unacked non-ok with ticket ≥ 312 | 96 (current swarm jobs, out of scope) |
| `jobs/` dir | 5 pending job files 00000408-00000412 (freshly 00000408-00000413) |
| `godot.lock` | exists / held (current in-flight job) |
| ack metadata spot-check | ticket 16 `timed-out acknowledged=true ack_reason? true`; ticket 292 same; ticket 22 `ok` untouched; 296/300 untouched; 398 `ok` untouched |

By the **history** signal of the clean gate the variant spool is now clean: every
failure-status entry is acknowledged. The **process** signal is DIRTY because a current
job is running, and the shipped gate tool reads the wrong spool.

## 6. Verdict

**NOT CLEAN — formal 3D CLEAN verdict is NOT claimed at this time.**

Evidence-based reasoning:

1. **Hygiene goal achieved on the history signal:** all 22 historical unacked
   `timed-out` jobs (ticket < 312) were acked with concrete reasons citing verified
   PASS supersedes; the variant spool now has **0 unacked failure-status jobs**. This
   closes COMP-05 F-02's history precondition and the qualification at
   `STATUS_WAVE7_PHASE2.md:46-50` *as far as ack hygiene is concerned*.
2. **No green claim without tool output:** the last required tool run returned
   `VERDICT: DIRTY`, exit 1, with a live Godot process, and the variant queue has 6
   pending tickets plus a held lock. `CLEAN_GATE.md:100-103` forbids signing a gate on
   a busy queue. Acking does not, and must not, change this.
3. **The shipped variant gate tool is mis-wired:** `variant3d/tools/assert_clean.py:34`
   reads `app/.godot_queue`; its initial "CLEAN" output was 2D evidence, not variant
   evidence. A correct variant verdict requires either fixing that path (not in this
   worker's scope) or an explicit variant-spool assertion; this report provides the
   direct file-read equivalent in §5, but it is not a tool-issued variant CLEAN.

A formal CLEAN verdict can be claimed only after (a) the current jobs drain and the
queue is quiet, (b) `assert_clean.py` is pointed at `variant3d/.godot_queue` (or an
equivalent variant gate is run and recorded), and (c) a clean tool output is captured.

## 7. Remaining open / unexplained failures

| Ticket | id | Status | Why left unacked | Gate impact |
|---:|---|---|---|---|
| 296 | `play2fix-navbox-probe-before` | failed | `PLAY2FIX_navbox.md:54` calls it an INVALID baseline (bind before tree, `get_viewport()` null); later job 300 measured real values but also `failed` on y-centre assertions; no documented PASS supersede, and FAST-LANE skipped the selftest. Genuinely unexplained → left unacked. | None — `failed` is excluded by D-13 |
| 300 | `play2fix-navbox-probe-after` | failed | `PLAY2FIX_navbox.md:56` reports valid measurement but all three y centres −3 tiles off; no later PASS probe; FAST-LANE skipped selftest. Genuinely unexplained → left unacked. | None — `failed` is excluded by D-13 |
| ≥ 312 | 96 current unacked non-ok jobs | failed/ok mix | Current swarm jobs (tickets 312-413) explicitly out of scope; some still running/pending. Must not be acked. | Not gated by this worker; current churn |

No `timed-out` / `error` / `skipped` job remains unacked on the variant spool.

## 8. Summary and files modified

- Enumerated 100 historical unacked non-ok results with ticket < 312; acked 98 with a
  documented, queue-verified PASS supersede; left 2 unexplained `failed` jobs unacked.
- All 22 gate-relevant `timed-out` jobs are now acknowledged; variant history signal is
  clean (0 unacked failure-status jobs).
- Re-ran both required tools; outputs recorded verbatim in §4. Final tool verdict was
  **DIRTY** (live current Godot job), so no formal CLEAN verdict is claimed.
- **Files modified:**
  - 98 result JSONs under `variant3d/.godot_queue/results/00000000.json` …
    `00000309.json`: `acknowledged` / `ack_reason` / `ack_at` metadata **only**
    (via the runner's `ack` command). No result file with ticket ≥ 312 was touched;
    no result was deleted.
  - `variant3d/.godot_queue/status.json`: the same three ack fields on the 98 matching
    history entries, synced automatically by `cmd_ack`. No queue state, counter,
    `now_serving`, lock or pending job was changed. No reset was run.
  - Exclusive report outputs authored: this file and
    `inbox/backup/godot_queue_status_backup.md` (pre-ack text snapshot).
  - No other repo file was authored or edited. No Godot job was launched, cancelled or
    killed by this worker.
