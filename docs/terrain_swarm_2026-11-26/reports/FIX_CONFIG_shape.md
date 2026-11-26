---
id: FIX-CONFIG
ticket: "TERRAIN-SWARM-2026-11-26 / donor-terrain VISUAL WAVE (SECONDARY)"
agent: "worker FIX-CONFIG, reporting to COORD"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/FIX_CONFIG_shape.md
files_created: [docs/terrain_swarm_2026-11-26/reports/FIX_CONFIG_shape.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "Config-key audit only. No donor GPU A/B frame exists; no donor-fidelity or parity claim is made."
scope_guard: "Read-only source/config audit. No code, shader, asset, config, test, gate or git edit; no Godot job; no donor binary executed. Exactly one repository file written: this report."
---

# FIX-CONFIG — W03 config conflict: effective donor shape

## 0. Verdict

**[D]/[I] W03 P2 is confirmed.** The capture overlay requests
`gameplay.map_type = "land"` (`map_donor_240.json:113`), but the overlay omits
`gameplay.terrain_type`, so the built-in default `"mediterranean"`
(`config.gd:127`) survives the key-by-key merge. Both the sim's `Data.MAP_TYPE`
resolution (`config.gd:535`) and I17 `_shape_of()` (`terrain_donor_inputs.gd:161-164`)
read **`terrain_type` first**, so the effective I17 mask-shape string is
`mediterranean`, not `land`.

**Minimal fix for COORD's full capture overlay — add the one decisive key:**
`gameplay.terrain_type = "land"`.

**Recommended (unambiguous) fix — set the pair, both `"land"`:**
`"map_type": "land"` *and* `"terrain_type": "land"` inside `gameplay`.

`gameplay.map_shape = "land"` is **not** a substitute: `_shape_of()` never reads it.

This is an **I17 input-selection** defect (which derived mask asset is chosen),
**not** a defect in the donor generator itself (I07 `terrain_donor_gen.gd`). See §5.

---

## 1. Pass A — `config.gd` merge logic (why the default survives)

Two independent reads of the same files were made; both agree.

| Step | Source | Effect |
|---|---|---|
| A1 | `config.gd:90-143` `DEFAULT.gameplay` holds **both** `"map_type": "mediterranean"` (:125) and `"terrain_type": "mediterranean"` (:127). | Two keys, same default value. |
| A2 | `config.gd:275-304` `load_all()` starts with `base = _copy(DEFAULT)` (:276), then merges the discovered config file (:282), then the `--config` overlay `extra_path` (:290), then `user://options.json` (:302). | Overlay is applied *over* defaults, not in place of them. |
| A3 | `config.gd:378-386` `_merge()` recurses only when both sides are Dictionaries; every other value replaces. | A scalar overlay key replaces only that key; sibling keys are untouched. |
| A4 | Overlay `map_donor_240.json:113` sets only `gameplay.map_type = "land"`; there is **no** `gameplay.terrain_type` key in the file (`map_donor_240.json:78-115`). | Merge overwrites `map_type`, leaves `terrain_type = "mediterranean"` from A1. |
| A5 | W03 P2 found no `user://options.json` in the Godot user-data roots; nothing in the third layer rewrites it. | No later correction. |
| A6 | `config.gd:535` `Data.MAP_TYPE = text("gameplay.terrain_type", text("gameplay.map_type", "mediterranean"))`. | `terrain_type` is the **primary**; `map_type` is only its fallback. Result: `Data.MAP_TYPE = "mediterranean"`. |
| A7 | `config.gd:594-597` donor-id fallback `if not gsec.has("terrain_type") and not gsec.has("map_type"):` | False — both keys are present — so the `DONOR_MAP_SHAPE`-based override of `Data.MAP_TYPE` does **not** run. Adding `map_shape` cannot repair this path. |

**Pass A conclusion [D]:** after load+apply the effective config is
`map_type="land", terrain_type="mediterranean"`; `Data.MAP_TYPE` resolves to
`mediterranean` because of the `terrain_type`-first expression at :535.

Cross-check: `data.gd:233` documents that `terrain_type` is deliberately
aliased onto `MAP_TYPE`, and `menu.gd:707` writes both keys together when a
human picks a shape — so the two keys are intended to be a *single* value held
in two places. The overlay providing only one of them is the inconsistency.

---

## 2. Pass B — I17 `_shape_of()` (why the shape becomes mediterranean)

Source: `terrain_donor_inputs.gd:152-168`, called from `build()` at `:625`, with
`game` handed in by the composer at `terrain_donor_world.gd:229-233`.

Pass B, branch by branch:

1. **Game-object loop** (`:156-159`): checks
   `shape, map_type, MAP_TYPE, terrain_type, TERRAIN_TYPE, biome` on `game`
   and returns the first non-empty string. Note the order here is
   `map_type` *before* `terrain_type`. In the live capture no such string is
   supplied on the bound object (W03 P2/P3: the reported shape came from the
   config branch), so the loop falls through. **[O]/[D]**
2. **Config branch** (`:160-167`): calls
   `text("gameplay.terrain_type", "")` **first** (:162-164) — returns
   `"mediterranean"` from A5. It returns immediately, so the
   `text("gameplay.map_type", "")` fallback at `:165-167` — which would have
   returned `"land"` — is **never reached**. **[D]**
3. **`_select_mask()`** (`:180-222`) then filters `mask_index.json` entries by
   `shape == "mediterranean"`; W03 P3 replay picked DLC5
   `4pl_mask_mediterranean_29_gauss.height.png` (index 78/446). **[D], matches W03**

This is the exact inversion described in W03 §2.1 and §5: the game-object loop
would prefer `map_type`, but the config branch that actually fires prefers
`terrain_type`. Because the default `terrain_type` was never overwritten, the
capture's `map_type="land"` is inert.

**Pass B conclusion [I]:** effective donor shape = `mediterranean`. Both passes
(config resolution and I17 resolution) select the same value; the conflict is
fully explained by one missing overlay key.

---

## 3. Exact minimal keys for the full capture overlay

Add inside the `gameplay` object of the full capture overlay:

```json
"gameplay": {
  ...
  "map_type": "land",        // already present (map_donor_240.json:113)
  "terrain_type": "land"     // ADD — decisive: overwrites config.gd:127 default
}
```

- **Single decisive key:** `"terrain_type": "land"`. It overwrites the default
  via `_merge()` (A3), makes `config.gd:535` yield `"land"`, and makes I17's
  config branch (`:162-164`) yield `"land"`. This is the exact donor key I17 reads.
- **Recommended pair:** set **both** `map_type` and `terrain_type` to `"land"`.
  This keeps the two aliased keys consistent (as `menu.gd:707` does), covers the
  game-object loop's opposite precedence (`map_type` first, `:156`), and makes
  the shape unambiguous regardless of which consumer reads it. `config.gd:595`'s
  "neither key present" guard stays false, so no donor-id fallback interferes.
- **Not sufficient:** `"map_shape": "land"` alone. It feeds
  `Data.DONOR_MAP_SHAPE` (`config.gd:577`) and the menu path (`main.gd:300-307`),
  but `_shape_of()` has no `map_shape` lookup. Adding only `map_shape` leaves the
  I17 shape `mediterranean`. Likewise `"shape"` is only a *game-object*
  property in `_shape_of()` (`:156`), not a config key.

**Expected after fix [D]:** `Data.MAP_TYPE="land"` and I17 `shape="land"`;
`_select_mask()` filters on `"land"` and finds matching entries (e.g.
`mask_index.json:99043` `"shape": "land", "tree": "dlc5"`), so the
`"MASK no entry for shape ..."` skip at `:207` no longer fires.

**What this fix does NOT do [D]:** it does not repair the 320×320-over-240×240
grid overwrite (`terrain_donor_inputs.gd:268-269`), the pooled `.src`/DLC5/
vanilla candidate tree, the 4pl-vs-2pl mask mismatch, the missing relief-stamp
placement (`terrain_donor_gen.gd:2026-2039`), or the I10 UV lattice. Those are
separate W03 fix items (b), (c), (f).

---

## 4. Evidence / label register

| Ref | Observation | Label |
|---|---|---|
| `config.gd:125,127` | Both default shape keys = `mediterranean` | [O] |
| `config.gd:275-304,378-386` | Defaults copied, overlay merged key-by-key | [O] |
| `map_donor_240.json:78-115,113` | Overlay sets `map_type=land`, no `terrain_type` | [O] |
| `config.gd:535,594-597` | `terrain_type` primary; donor-id fallback guard false | [O]/[D] |
| `terrain_donor_inputs.gd:155-168` | `_shape_of()` config branch reads `terrain_type` first | [O]/[D] |
| W03 P2/P3 | Effective shape `mediterranean`; DLC5 4pl mask index 78 | [I] |
| `mask_index.json:99040-99046` | `shape="land"` entries exist (dlc5, 320×320) | [O] |
| `data.gd:233`, `menu.gd:707` | `terrain_type`/`map_type` intentionally alias one value | [O]/[I] |
| Overlay key recommendation | Derived consequence of A1-A7 + B1-B3 | [D]/[I] |
| Generator scope (§5) | Derived from I07 `p` contract / call graph | [D] |

Unknowns [U]: runtime `options.json` on the capture host was not re-searched in
this worker (W03 P2 reported none); no capture was re-run, so the post-fix
shape/mask identity is a source-derived prediction, not telemetry.

---

## 5. Scope: generator vs I17 input selection

**[D] This affects I17 input selection (and the port's `Data.MAP_TYPE` label),
not the donor generator itself.**

- I07 `terrain_donor_gen.gd` receives only the `p` Dictionary built by I17
  (`terrain_donor_world.gd:229-240`); it never reads `gameplay.terrain_type`,
  `map_type`, or `map_shape` from config. The `terrain_type` grep across
  `variant3d/scripts` shows no consumer in `terrain_donor_gen.gd` (only
  `max_terrain_types` at `:806`, unrelated).
- Therefore changing the overlay key changes **which derived mask asset I17
  selects and hands to I07**, not I07's algorithm, decode, smoothing, stamping,
  mesh, or shader. The generator would run the identical pipeline on a
  different `p.mask_b`/`p.width`/`p.height`.
- The only non-I17 effect is the sim-side shape label: `Data.MAP_TYPE`
  (`config.gd:535`) and `map_meta["type"]` (`game.gd:1177`), both port-side
  consumers of the same aliased value. Neither is a donor-generator behaviour.

---

## 6. Handoff to COORD

1. Add `"gameplay.terrain_type": "land"` to the full capture overlay; preferably
   also keep `"gameplay.map_type": "land"` so the aliased pair is consistent.
2. Do **not** use `gameplay.map_shape` as the I17 shape fix.
3. Treat the W03 (b)/(c)/(f) items as independent repairs; this config fix only
   makes the requested shape actually reach I17.

**NO DONOR VISUAL PARITY CLAIM. Parity remains UNVERIFIED.**

*End of FIX-CONFIG. Exactly one repository file written; no code/shader/asset/config/test edit, no Godot job, no gate, no git operation.*
