---
id: RELIEF-02
title: "Producer-side dump[\"relief_stamps\"] marker from donor-grounded pattern stamps (plt2 emitted; k_ravine_1 blocked)"
agent: RELIEF-02 (integration builder, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — two owned files only; donor READ-ONLY (only transcribed numbers/citations read); no donor binary copied/run; one variant-runner smoke
scope: minimal additive producer hook in main.gd:_dump_map(); no edit to world3d_terrain.gd / game.gd / pattern_gen.gd / tests / config / shaders / app/**
owner_files:
  - variant3d/scripts/main.gd
  - docs/coord_swarm_2026-11-25/reports/RELIEF_02_stamp_marker.md
  - inbox/backup/main.gd.bak-RELIEF02 (backup artifact, not a source file)
backup: inbox/backup/main.gd.bak-RELIEF02 (81,910 B, pre-edit; SHA-256 813E588940F15564AB31FCDB6EB60675B35C80CDF9954DC25FA9CEABC62EACBE)
smoke: "python variant3d\\tools\\godot_runner.py run --id relief02-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/main.gd"
verdict: PLT2_PRODUCER_ADDED__K_RAVINE_1_BLOCKED__PORT_APPROX__ENGINE_BLEND_UNVERIFIED
labels: [observed, derived, PORT APPROXIMATION, UNVERIFIED, BLOCKED (partial)]
---

# RELIEF-02 — supply the `dump["relief_stamps"]` marker

> [!IMPORTANT]
> Donor is truth; donor files were read in place only, never copied, run or
> edited. The stamp name comes from donor-derived pattern data, but the port's
> placement and the sculpt blend are **PORT APPROXIMATIONS** — donor engine
> blend is **UNVERIFIED** (DPATTERN-01 §5.2, report lines 348-382).
> Only one Godot process was launched, through the variant runner; no direct
> `godot`, no gates, no ladder.

---

## 1. Evidence read (all read-only)

| Source | Fact used |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/RELIEF_01_stamping.md:60-67,71-91,210-221` | Dump schema has no relief marker; RELIEF-01 reader contract `{"name","cx","cy",scale?,footprint_w?,footprint_h?}`; integration ticket asks for a producer from `game.pattern_stamps` (`game.gd:64-70,881-981`) |
| `RELIEF_01_stamping.md:117-131,166-184` | Additive-clamp blend is a labelled PORT APPROXIMATION; `RELIEF_TABLES` accepts exactly the two ids `k_ravine_1`, `plt2`; clamp min/max verified from `pattern.lib` |
| `DPATTERN_01_relief_grids.md:142,154` | Donor ids: `k_ravine_1` (family `ravine_medium`, `generator.cfg:540`, `pattern.lib:549585-549586`); `plt2` (family `plateau`, `generator.cfg:588`, `pattern.lib:6805-6806`) |
| `DPATTERN_01_relief_grids.md:302-346` | Placement via `dogenerate.inc:1621-1765` + `generator.cfg` `Freq`; `ravine_medium` is `//`-disabled at `:1760`, active ravine family is `ravine_big` at `:1761` — consistent with the port's recipe table |
| `DPATTERN_01_relief_grids.md:348-382` | Sculpt config exists only in `pattern.lib`, no plaintext consumer; engine blend UNVERIFIED, additive-clamp is the safe port reading |
| `DPATTERN_01_relief_grids.md:595-626` (Appendix A1/A2) | The two coarse 8×10 tables encoded by RELIEF-01 |
| `variant3d/scripts/main.gd:710-750` (pre-edit) | `_dump_map()` builds the dump after `game.setup(start_mode)`: keys `seed, map_w, map_h, terrain, blocked, height, tileblock, starts, clusters, res, meta` — no relief field |
| `variant3d/scripts/world3d_terrain.gd:354-455,1051-1061` (read-only) | Consumer `_apply_relief_stamps_from_dump()` reads `dump["relief_stamps"]`, accepts JSON int or float `cx/cy`, falls back to map centre, and calls `apply_relief_grid()`; with no marker it returns 0 and `build()` is byte-identical to baseline |
| `variant3d/scripts/terrain3d_sandbox.gd:65-82` | The parsed dump Dictionary is passed whole to `world3d.gd:build_from_dump()`; no strict key enumeration, so an extra key is additive |
| `variant3d/scripts/game.gd:46,64-70,306-309,673-687,881-903,1078-1080` | `pattern_stamps` is a public Array; `setup()` calls `_gen_base()` then `_gen_patterns()`; `_gen_patterns()` assigns `pattern_stamps = result.get("stamps", [])` before `_dump_map()` reads it. `map_meta["stamp_counts"]` holds only kind counts — no names/positions — so `pattern_stamps` itself is the usable hook |
| `variant3d/scripts/pattern_gen.gd:4-5,40-57,132-151,158-190,474-549` | `Stamp` carries `family/name/kind/x/y/cells`; `name` is picked from `donor_patterns.json` families and `x/y` are map-cell indexes; relief recipes at `:27-36` include `plateau` (`:32`) and `ravine_big` (`:31`) but **not** `ravine_medium` |
| `variant3d/assets/terrain/patterns/donor_patterns.json` (read-only, parsed with Python 3.14) | `source` field: donor `data/pattern/*.pattern` + `data/game/var/generator.cfg`; 43 families / 282 patterns. `plt2` present with Freq 1.0 in `plateau` family (`[["plt1",1],["plt2",1],…]`); `k_ravine_1` **absent** — only `k_ravine_big_stone_1..8` exist, in `ravine_big` |

---

## 2. Producer-marker determination

**FOR a producer marker (one of the two ids).** A donor-grounded marker is
already reachable from `main.gd` without editing `game.gd`:

1. `game.gd:306-309` → `setup()` runs `_gen_base()` (builds `_pattern_build` at
   `game.gd:1078`) and `_gen_patterns()` (assigns `pattern_stamps` at
   `game.gd:681`). `_dump_map()` calls `game.setup(start_mode)` at
   `main.gd:722-724`, so the array is populated before the dump is built.
2. `pattern_gen.gd:164,179-187` and `:515-539` put the donor pattern id into
   `Stamp.name` and the map-cell placement into `Stamp.x/Stamp.y`; the id is
   drawn from `donor_patterns.json`, whose `source` field cites the donor
   `.pattern` files and `generator.cfg` (`pattern_gen.gd:4-5,42`).
3. `plt2` is a real member of the `plateau` family (Freq 1) and
   `pattern_gen.gd:32` includes `["plateau","plt",3.0,"plateau"]` in
   `RELIEF_RECIPES`, so relief stamps with `name == "plt2"` are genuinely
   produced. Emitting `{"name": "plt2", "cx": st.x, "cy": st.y}` is therefore
   a mapping of **observed donor-grounded data**, not an invented stamp.

**AGAINST / BLOCKED (the other id).** `k_ravine_1` cannot be emitted from any
reachable data:

- `k_ravine_1` is absent from `donor_patterns.json` `patterns` and from every
  `families` list; `ravine_medium` (its donor family, `generator.cfg:540`) is
  not exported at all.
- `pattern_gen.gd:27-36` has no `ravine_medium` recipe; its only ravine family
  is `ravine_big` (`k_ravine_big_stone_1..8`). This mirrors donor intent:
  `dogenerate.inc:1760` `//`-disables `ravine_medium`, `:1761` uses `ravine_big`
  (DPATTERN-01:341-346).
- `game.map_meta["stamp_counts"]` (`game.gd:683-687`) has only `kind` counts, so
  it cannot supply a name or a centre either.

Per the directive, **no `k_ravine_1` marker was invented**. The filter in
`main.gd` names both ids because both are in RELIEF-01's `RELIEF_TABLES`, but it
only ever copies names that actually occur in `game.pattern_stamps`; in current
data that is `plt2` (or an empty array).

---

## 3. Before → after (backup → current)

Backup: `inbox/backup/main.gd.bak-RELIEF02`, byte-identical pre-edit copy
(SHA-256 `813E588…ACBE`). `git diff --no-index --stat` reports
**18 insertions, 0 deletions** — purely additive.

| Before (`main.gd.bak-RELIEF02`) | After (current `main.gd`) | Change |
|---|---|---|
| `_dump_map()` ended its body at old `:735` (zones loop) | new `:736-752` | Producer block: derive `relief_stamps` from `game.pattern_stamps`, filtered to `plt2` / `k_ravine_1`, each entry `{"name","cx","cy"}`, with PORT APPROXIMATION / donor citation comment |
| dump dict at old `:736-743` (11 keys) | `:754-761` | Added one key `"relief_stamps": relief_stamps` |

Unchanged by construction: all 11 pre-existing dump keys and their values,
`game.setup()` call order, RNG consumption, `seed`, base64 payloads,
`_dump_self_base()` (a separate schema at `main.gd:754-771` — deliberately not
touched), `world3d_terrain.gd`, `game.gd`, `pattern_gen.gd`, tests, config,
shaders and `app/**`.

Resulting marker (JSON round-trip turns `cx/cy` into floats; the reader accepts
both int and float at `world3d_terrain.gd:435-440`):

```json
"relief_stamps": [
  {"name": "plt2", "cx": <map cell x>, "cy": <map cell y>}
]
```

An empty array is emitted when no matching stamp was generated — still a
no-op in the consumer. The 10×8 footprint and scale 1.0 come from RELIEF-01's
defaults; the donor pattern's true extent and the engine sculpt are
**UNVERIFIED**.

---

## 4. Validation (variant runner only)

Exactly one Godot job — no direct `godot`, no gates, no ladder:

```
python variant3d\tools\godot_runner.py run --id relief02-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/main.gd
```

| Field | Observed result |
|---|---|
| Ticket / id / status / exit | **415** / `relief02-smoke` / `ok` / **0** |
| Wait / run | 302.46 s (shared FIFO) / 9.29 s |
| Result file | `variant3d\.godot_queue\results\00000415.json` |
| stderr | `…\00000415_relief02-smoke\stderr.txt` = **0 bytes → `SCRIPT ERROR == 0`** |
| stdout | Godot 4.7.2 banner only (75 bytes), no parse/compile error |

`--check-only --script res://scripts/main.gd` is a parse/compile check of the
edited producer file; it does not execute `_dump_map()`, so it proves the edit
introduces no script error but **does not prove** a plt2 marker is emitted at
runtime. A functional dump assertion is listed under open questions.

---

## 5. BLOCKED sub-ticket — `k_ravine_1` producer hook

**RELIEF-02-FOLLOWUP (BLOCKED, not executed).** To emit a donor-grounded
`k_ravine_1` marker, an owning builder must first make that pattern reachable:

1. Export `ravine_medium` / `k_ravine_1` from the donor
   (`generator.cfg:540-576`, `pattern.lib:549585-549586`) into
   `assets/terrain/patterns/donor_patterns.json` (or add an explicit producer
   field) — owner of `pattern_gen.gd` / asset export, **not** this agent.
2. Add a `ravine_medium` entry to `RELIEF_RECIPES` (`pattern_gen.gd:27-36`) if
   the generator should actually place it. **Parity caveat:** donor
   `dogenerate.inc:1760` `//`-disables `ravine_medium` and stamps `ravine_big`
   at `:1761` (DPATTERN-01:341-346), so enabling it changes family coverage —
   a decision, not a mechanical fix.
3. Alternatively, a `game.gd`-side producer can emit a marker from a
   `k_ravine_1` placement made by a different system; until one exists, any
   `k_ravine_1` entry in the dump would be fabricated and is forbidden here.

Acceptance when unblocked: a dump with one `k_ravine_1` marker should yield at
least one `height < −2.0` cell through RELIEF-01's reader while preserving
4,096 / 7,938 / 1 surface at 64² (RELIEF-01 §7).

---

## 6. Explicit UNVERIFIED / APPROXIMATION labels

1. **Engine sculpt blend** — additive-clamp remains a PORT APPROXIMATION;
   `Replace`, `ReplaceForWater`, `Smooth`, clamp/scale order are UNVERIFIED
   (DPATTERN-01 §5.2, §9 Q2).
2. **Placement** — `Stamp.x/y` come from the port's RNG placement
   (`pattern_gen.gd:523-524`), which mirrors donor intent but is not a donor
   byte-for-byte replay (donor placement is engine-side, `dogenerate.inc:1621-1765`).
3. **Footprint/extent** — RELIEF-01's 10×8 coarse window is a port convenience,
   not a donor-verified stamp extent (DPATTERN-01 Appendix A warns the coarse
   tables are debug/preview aids).
4. **Row flip** — file-row→map-row sign UNVERIFIED (DPATTERN-01 §9 Q3);
   RELIEF-01 keeps file order.
5. **Producer completeness** — only `plt2` is genuinely emitted today;
   `k_ravine_1` is blocked (§5). No random stamps were fabricated.
6. **Runtime coverage** — the smoke is a parse check, not a dump-content or
   GPU A/B check.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Which relief presets/seeds actually place a `plt2` stamp (name is picked
   by `pattern_gen.gd:132-151` from 5 plateau patterns with equal Freq)? A
   runtime dump-content assertion is needed.
2. Does the donor ever stamp `ravine_medium` outside the skirmish path cited
   at `dogenerate.inc:1760`? If not, is `k_ravine_1` worth unblocking at all?
3. How should the port reconcile `plt2` max `+3.6134` (`pattern.lib:6806`)
   with its later global cap `+2.964` (`game.gd:1096-1097`)? RELIEF-01 §5.6.
4. Should the producer emit `scale`/`footprint_w`/`footprint_h` (donor
   `HeightFieldScale`, extent) once those are verified, instead of relying on
   RELIEF-01 defaults?
5. Should the filter be widened to other decoded ids (`plt1`, `hil1`, …) after
   RELIEF-01 encodes their tables?
6. Does `build_from_dump()` receive a dump produced by `_dump_map()` in the
   normal variant flow (confirmed statically at `terrain3d_sandbox.gd:65-82`,
   not runtime-verified)?

---

## 8. Summary

- A donor-grounded producer marker is available in
  `game.pattern_stamps` (`game.gd:66,681` ← `pattern_gen.gd:4-5,164,179-187,
  515-539` ← donor `.pattern` + `generator.cfg`); the RELIEF-01 integration
  ticket asked for exactly this hook.
- Added a minimal, additive producer in `variant3d/scripts/main.gd:_dump_map()`
  that emits `dump["relief_stamps"] = [{"name": "plt2", "cx": st.x, "cy": st.y}]`
  for real `plt2` stamps only, filtered to the two ids RELIEF-01 knows.
  `k_ravine_1` is absent from reachable donor data, so **no** such stamp was
  invented; its producer hook is reported BLOCKED (§5).
- Backup: `inbox/backup/main.gd.bak-RELIEF02` (81,910 B, pre-edit). Diff:
  **+18 / −0** lines in `main.gd` only.
- Smoke: runner ticket **415**, `relief02-smoke`, exit 0, stderr 0 bytes
  (**`SCRIPT ERROR == 0`**). No gates/ladder/direct `godot`.
- **Files changed by this agent:** `variant3d/scripts/main.gd` and this report
  (`docs/coord_swarm_2026-11-25/reports/RELIEF_02_stamp_marker.md`); one backup
  artifact `inbox/backup/main.gd.bak-RELIEF02`. No other source, test, config,
  shader, donor file or `app/**` file was edited. Runner result artifacts
  under `variant3d/.godot_queue/results/00000415*` are harness output.
- **Concurrent swarm commit:** another builder's commit `b1332b91` ("step")
  swept the already-written `main.gd` edit and backup into HEAD while this job
  was running; this agent did **not** run `git add`/`git commit`. That is why a
  later `git status` shows those two paths as clean and only this report as
  untracked. The diff against the backup above is unchanged.

*End of RELIEF-02.*
