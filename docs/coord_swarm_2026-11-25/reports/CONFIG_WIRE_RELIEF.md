---
id: CONFIG-WIRE-RELIEF
title: "Global feature config gates the donor relief-stamp producer in main.gd:_dump_map()"
agent: CONFIG-WIRE-RELIEF (small integration builder, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — one owned source file + this report; one variant-runner parse check (re-submitted after external cancellation)
scope: minimal additive gate on dump["relief_stamps"] emission; no producer/mapping changes; no other file
owner_files:
  - variant3d/scripts/main.gd
  - docs/coord_swarm_2026-11-25/reports/CONFIG_WIRE_RELIEF.md
  - inbox/backup/main.gd.bak-CONFIGWIRER (backup artifact, not a source file)
backup: inbox/backup/main.gd.bak-CONFIGWIRER (82,972 B, pre-edit; SHA-256 A485810ABF1977619AAED39F01F11D1DDF708C2885FFBDC4E78D9237E3802888, identical to pre-edit source)
smoke: "python variant3d\\tools\\godot_runner.py run --id configwirer-smoke-r2 --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/main.gd"
verdict: CONFIG_GATE_ADDED__DEFAULT_OFF_PRESERVES_BEHAVIOUR__PLT2_MAPPING_UNCHANGED__K_RAVINE_1_STILL_BLOCKED
labels: [observed, additive, no-behaviour-change]
---

# CONFIG-WIRE-RELIEF — let the global feature config gate the donor relief stamps

> [!IMPORTANT]
> The donor relief tables and their producer are unchanged. This ticket only
> gates *emission* of an already-existing marker behind the global feature flag
> added by CONFIG-CORE-01. Default `false` means no marker key is written, so
> the RELIEF-01 reader remains a no-op and behaviour is unchanged.

---

## 1. Evidence read (all read-only)

| Source | Fact used |
|---|---|
| `reports/CONFIG_CORE_01.md:43-47,60` | `features.terrain.relief_stamps` default `false`, typed getter `feature_terrain_relief_stamps() -> bool` (`config.gd:448-449`); missing key/section falls back to the constant |
| `config.gd:414-419,448-449` | Feature-reader block goes through `value()`-style getters; getter returns `flag("features.terrain.relief_stamps", false)` |
| `reports/RELIEF_01_stamping.md:71-91,210-221` | Consumer reads opt-in `dump["relief_stamps"]`; with no marker it returns 0 and `build()` is byte-identical to baseline |
| `reports/RELIEF_02_stamp_marker.md:88-118,144-164` | Producer block in `_dump_map()` emits the marker unconditionally today; `plt2` is donor-grounded; `k_ravine_1` is absent from reachable donor data and its producer hook is BLOCKED — no stamp was invented |
| `main.gd:736-761` (pre-edit) | Producer loop and dump dict: 11 pre-existing keys plus an unconditional `"relief_stamps": relief_stamps` |
| `hud.gd:276-292` | Established null-safe config-getter pattern: `if cfg != null and cfg.has_method(...): return ... cfg.call(...)` with a literal fallback |
| `main.gd:129,168-178,217-219` | `cfg` is an instance var initialised in `_ready()` before `_dump_map()` is invoked; null-safe guard still covers early/partial init |

## 2. Getter map (config → consumer)

| Config path | Typed getter (`config.gd`) | Default | Consumer use (this ticket) |
|---|---|---|---|
| `features.terrain.relief_stamps` | `feature_terrain_relief_stamps() -> bool` (`:448-449`) | `false` | `main.gd:_dump_map()` → `relief_enabled`; gates whether `dump["relief_stamps"]` is emitted |

Read null-safely, mirroring `hud.gd`:

```gdscript
var relief_enabled := false
if cfg != null and cfg.has_method("feature_terrain_relief_stamps"):
    relief_enabled = bool(cfg.call("feature_terrain_relief_stamps"))
```

A null `cfg`, a missing getter (older config build), or a missing config key all
resolve to `false` — i.e. the feature stays off and no marker is emitted.

## 3. Before → after (backup → current)

Backup: `inbox/backup/main.gd.bak-CONFIGWIRER`, byte-identical pre-edit copy
(SHA-256 `A485810…2888`, matching the source at backup time).
`git diff --no-index --stat` reports **12 insertions, 1 deletion** in
`main.gd` only.

| Before (`main.gd.bak-CONFIGWIRER`) | After (current `main.gd`) | Change |
|---|---|---|
| after old `:752` (producer loop) | new `:753-759` | Null-safe getter read into `relief_enabled` (CONFIG-WIRE-RELIEF comment block + 3 code lines) |
| dump literal at old `:753-761` had unconditional `"relief_stamps": relief_stamps,` at `:760` | new `:762-767` (literal now ends at `:766`) | Removed the unconditional key; added `if relief_enabled: dump["relief_stamps"] = relief_stamps` after the literal |

Unchanged by construction:

- The full RELIEF-02 producer loop: `game.pattern_stamps` iteration, the
  `plt2` / `k_ravine_1` name filter, and `{"name","cx","cy"}` construction —
  **not one line edited**. `plt2` remains donor-grounded; `k_ravine_1` remains
  BLOCKED (absent from `donor_patterns.json`, never fabricated).
- All 11 pre-existing dump keys, their values, call order, RNG consumption and
  base64 payloads.
- `_dump_self_base()` schema, `game.setup()` order, world3d_terrain.gd,
  config.gd / config.json, tests and `app/**`.

Resulting behaviour:

- **flag false (default / missing key / no config):** dump has no
  `relief_stamps` key at all — byte-identical to the pre-RELIEF-02, relief-off
  baseline. No stamping, no topology change.
- **flag true:** dump gains `dump["relief_stamps"] = relief_stamps`, i.e. the
  exact array RELIEF-02 already produced (empty when no matching stamp). The
  consumer then applies its existing, labelled PORT APPROXIMATION blend.

## 4. Validation (variant runner only)

Exactly one re-submitted Godot job — no direct `godot`, no gates, no ladder.
The first job (`configwirer-smoke`, ticket **449**) was **CANCELLED by
QA-PARITY-01's cleanup mistake**, not by a code failure; it is not a parse or
regression result and was not reverted against. Per the coordination notice it
was replaced by a new unique id, submitted once (no re-submit of a slow queue
job).

| Field | Observed result |
|---|---|
| Ticket / id / status / exit | **464** / `configwirer-smoke-r2` / `ok` / **0** |
| Wait / run | 1178.37 s (shared FIFO) / 17.07 s |
| Result file | `variant3d\.godot_queue\results\00000464.json` (+ `00000464_configwirer-smoke-r2\`) |
| stdout | 75 B — Godot 4.7.2 banner only, no parse/compile error |
| stderr | **0 B → `SCRIPT ERROR` occurrences = 0** |

**`SCRIPT ERROR == 0` — confirmed.** `--check-only --script res://scripts/main.gd` is a parse/compile check of the
edited file; it does not execute `_dump_map()`, so it proves the gate introduces
no script error but does not prove a runtime marker is emitted. A functional
dump-content assertion remains an open question.

## 5. No-behaviour-change statement

With `features.terrain.relief_stamps` at its default `false` (or absent), the
dump written by `_dump_map()` contains exactly the same 11 keys and values as
before RELIEF-02's marker was added; the missing key makes RELIEF-01's reader
return 0 without touching any height. Enabling the flag is the only way to
restore RELIEF-02's marker emission, and even then the emitted array, donor
mapping and sculpt path are the ones already built and verified by RELIEF-01/02.
No existing key was renamed, reordered in meaning, or given a new value.

## 6. Open questions (UNVERIFIED — do not guess)

1. A runtime dump-content assertion is still needed: which presets/seeds
   actually place a `plt2` stamp, and does the flag gate it as expected?
   `--check-only` cannot answer this (RELIEF-02 §7 Q1).
2. `k_ravine_1` remains BLOCKED: exporting `ravine_medium` / `k_ravine_1` from
   the donor and adding a `RELIEF_RECIPES` entry is a separate, owner-gated
   decision (RELIEF-02 §5). No marker was fabricated here.
3. Config schema ownership stays with MAP-SMALL-01 / the JSON ticket; the
   getter already tolerates any subset of the `features` table.
4. The donor engine sculpt blend, placement and footprint remain PORT
   APPROXIMATION / UNVERIFIED (DPATTERN-01 §5.2, §9); this ticket does not
   change those labels.
5. Whether a future ticket should also gate the producer *loop* (to skip the
   `pattern_stamps` walk when disabled) rather than only the key emission;
   today the loop still runs but its result is discarded when the flag is off.
6. The re-submitted parse check covers only `main.gd`; the consumer's
   no-marker path was exercised by RELIEF-01's own smoke (`relief01-smoke`).

## 7. Incident line

- `configwirer-smoke` (ticket 449) was cancelled externally by QA-PARITY-01's
  cleanup mistake — **not** a parse/regression failure. Work was not reverted.
  The runner later reported `[runner] ticket 449 skipped: ticket 449 waited >
  1800s for its turn` (exit 1), confirming it never ran Godot.
- `configwirer-smoke-r2` was submitted once through the variant runner per the
  coordination notice; queue FIFO wait is expected and the job was never
  re-submitted while slow.
- A concurrent swarm commit (`49aa81f7 step`) swept the already-written
  `main.gd` edit and the backup into HEAD while this job was queued; this agent
  did **not** run `git add` / `git commit`. That is why `git status` shows only
  this report as modified while the on-disk diff against the backup above is
  unchanged.

## 8. Summary

- Added a global-config gate in `main.gd:_dump_map()`: a null-safe read of
  `feature_terrain_relief_stamps()` and conditional emission of
  `dump["relief_stamps"]` only when enabled.
- Default `false` (also the fallback for null/missing config or getter)
  preserves today's relief-off behaviour exactly — no marker key, no stamping.
- Donor-grounded `plt2` mapping and the BLOCKED `k_ravine_1` handling are
  byte-unchanged; no marker was fabricated.
- Backup: `inbox/backup/main.gd.bak-CONFIGWIRER` (82,972 B). Diff:
  **+12 / −1** lines in `main.gd` only.
- Validation: see §4 (re-submitted `configwirer-smoke-r2`; original ticket 449
  cancelled externally). No gates, no ladder, no direct `godot`.
- **Files changed by this agent:** `variant3d/scripts/main.gd` and this report,
  plus one backup artifact. **No other file edited** — not
  `world3d_terrain.gd`, `config.gd` / `config.json`, any test, or `app/**`.

*End of CONFIG-WIRE-RELIEF.*
