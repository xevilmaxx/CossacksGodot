---
id: DECOR-01
owner: DECOR-01
swarm: coord_swarm_2026-11-25
date: 2026-11-25
scope: "Implementation builder. Edits ONLY variant3d/scripts/world3d_entities.gd and this report. Donor READ-ONLY (no donor bytes copied)."
labels: [DONOR_TRUTH, TREES, MINES, ENVSCALES, JITTER_BANDS, IMPLEMENTATION]
status: DONE__POOL_6_TO_19__PER_SID_LADDER__THREE_BANDS__MINE_DISC_BLOCKED__YAW_UNVERIFIED__STAND_OPEN
backup: "inbox/backup/world3d_entities.gd.bak-DECOR01 (copy of the file before any edit)"
smoke: "variant runner ticket 358, --id decor01-smoke, status=ok exit=0, stderr SCRIPT ERROR == 0"
---

# DECOR-01 — tree/mine presentation fidelity in `world3d_entities.gd`

## 1. Scope and inputs read first

Read before editing: `reports/DTRN_04_donor_trees.md` (14+ tree actor families, envscale ladder
0.341–0.76 ±15 % jitter, authored yaw, 22 donor tree-ish sids vs live pool 6, all forced 0.5),
`reports/DTRN_05_donor_mines.md` (3 ores, scale 0.3152 **no** jitter, donor olive/beige cracked
ground disc stripped in the 2D port), `decomp/DEC_03_configs.md` §4.8 (three jitter bands:
`1/1` no wobble, `0.95–1.05` tight, `0.85–1.15` wide), `GAPS.md` §2 Trees/Mines rows, and
`PLAN_IMPLEMENTATION.md` DECOR-01 row. Then read the owned file in full at the cited seams.

No donor asset was copied, run or converted. No file outside the two owned files was edited.

## 2. Backup

```
copy variant3d\scripts\world3d_entities.gd inbox\backup\world3d_entities.gd.bak-DECOR01
```
Taken **before** the first edit. The diff below is `backup → live`.

## 3. Before → after (all in `variant3d/scripts/world3d_entities.gd`)

| # | Before | After | Evidence / citation |
|---|--------|-------|---------------------|
| 1 | `POOL_TREE` = 6 sids (`tree_spruce1, tree_pine, tree_fir, tree_oak, tree_spruce2, tree_pinedry1`) at old `:114-115` | `POOL_TREE` = **19** on-disk, resolvable wood sids at `:166-169`; measured 19/19 resolvable in `bind()` (`:309-314`, telemetry `:377`) | manifest.json:442-857 + `assets/models/obj/tree_*.obj` + `assets/models/tex/tree_*.png` all present; DTRN-04 C17/C18 |
| 2 | `ENV_SCALE = {"mine":0.3152,"stone":0.329,"tree":0.5}`; `_mesh_info` maps every `tree*` sid to 0.5 (old `:113`, `:721-727`) | `ENV_SCALE` **unchanged** (`:116`); new `ENV_TREE_SCALE` 18-sid ladder (`:134-145`), consumed by `_env_scale_factor()` (`:419-422`) and `_mesh_info()` (`:837`) | DTRN-04 C3, `envscales.cfg:158-585`; DEC-03 §4.8 |
| 3 | No jitter anywhere (single baked factor per sid) | New three-band map `ENV_JITTER_BANDS` (`:154-158`), deterministic `_hash01()` (`:427-432`) and `_jitter_factor()` (`:437-442`); per-instance **tree-only** multiplier applied in `_xf()` (`:1232-1239`) | DEC-03 §4.8; `envscales.cfg:162-164` ±15 % trees, `:19/25/31` mines `1/1` |
| 4 | Res-node yaw always 0 | **Unchanged** (yaw 0), explicit `TREE_YAW_STATUS` label + stats (`:176`, `:384`) | `game.gd:_add_res:509-510` carries no yaw/face/rot; `pattern_gen.gd` passes none → UNVERIFIED, no rotation invented |
| 5 | No forest-stand/decor pass; `invalidate_forest_bake()` NO-OP | No pass added; explicit `TREE_STAND_STATUS` (`:177`, `:385`) | DTRN-04 F3 requires a decor array + `game.gd`/`pattern_gen.gd` edits (other owners) → OPEN |
| 6 | Mine typed stamp/scale 0.3152 + jitter bypass already correct | **Untouched**. `ENV_SCALE["mine"]=0.3152` still read (`:116`/`:383`), `_jitter_factor("none")` returns exactly 1.0 and is never called for mines | DTRN-05 C5/§5.1; DEC-03 `:19/25/31` |
| 7 | No status telemetry for decor fidelity | `decor_*` stats keys added at `:375-388` (measurement/status only; no visual-parity claim) | honest labels required by the ticket |

Public API preserved **byte-for-byte in name and signature**: `bind`, `sync`, `add_unit`,
`add_building`, `add_resource(n)`, `remove`, plus `_resource_sid`, `POOL_TREE`, `ENV_SCALE`.
`resolve_mine_sid` lives in `game.gd:2685` (a consumer of the unchanged `mine_<ore>` sid mapping),
so it was not edited. Category names/counts unchanged: wood trees are still one
`res` node with `type=="wood"`; pool expansion only changes which donor sid a position hashes to.
`_env_group`, `_pick_sid`, `POOL_ROCK`, `POOL_BUSH`, `POOL_STUMP` are unchanged.

## 4. Sids and scale bands implemented

All 19 sids below were verified on disk (`obj` + `tex` PNG) **and** in `manifest.json` with a
bbox. The donor mesh column is read from `manifest.json:models[i].mesh` (READ-ONLY donor path).

| sid | donor mesh | envscale entry (line) | base | band |
|---|---|---|---:|---|
| `tree_fir` | `fir1.osm` | `fir` (`:161`) | 0.5 | wide 0.85–1.15 |
| `tree_firsmall1` | `firsmall1.osm` | `firsmall1` (`:196`) | 0.5 | wide |
| `tree_firsmall2` | `firsmall2.osm` | `firsmall2.2` (`:208`) | 0.5 | wide |
| `tree_firsmall3` | `firsmall3.osm` | `firsmall3.3` (`:214`) | 0.5 | wide |
| `tree_firsmall4` | `firsmall4.osm` | `firsmall4.4` (`:220`) | 0.5 | wide |
| `tree_spruce1` | `spruce1.osm` | `spruce1` (`:371`) | 0.5 | wide |
| `tree_spruce2` | `spruce2.osm` | `spruce1.1` (`:377`) | 0.5 | wide |
| `tree_spruce3` | `spruce3.osm` | `spruce2.2` (`:383`) | 0.5 | wide |
| `tree_spruce4` | `spruce4.osm` | `spruce3.3` (`:389`) | 0.5 | wide |
| `tree_pine` | `pine1.osm` | `pine1` (`:231`) | 0.475 | wide |
| `tree_pinesmall1` | `pinesmall1.osm` | `pinesmall1` (`:266`) | 0.55 | wide |
| `tree_pinesmall2` | `pinesmall2.osm` | `pinesmall2.2` (`:278`) | 0.56 | wide |
| `tree_pinesmall3` | `pinesmall3.osm` | `pinesmall3.3` (`:284`) | 0.61 | wide |
| `tree_pinesmall4` | `pinesmall4.osm` | `pinesmall4.4` (`:290`) | 0.5 | wide |
| `tree_pinedry1` | `pinedry1.osm` | `pinedry1` (`:406`) | 0.65 | wide |
| `tree_pinedry2` | `pinedry2.osm` | `pinedry2.2` (`:418`) | 0.706 | wide |
| `tree_pinedry3` | `pinedry3.osm` | `pinedry3.3` (`:424`) | 0.76 | wide |
| `tree_pinedry4` | `pinedry4.osm` | `pinedry4.4` (`:430`) | 0.5 | wide |
| `tree_oak` | `oak1.osm` | **no donor envscale group** (DTRN-04 §4.1 note) | 0.5 (legacy fallback, **UNVERIFIED**) | wide |

- Ladder entries: **18** (all values cited); 19th pool sid `tree_oak` deliberately keeps the old
  0.5 because there is no donor number for it. No value was invented.
- Band mapping follows DEC-03 §4.8 exactly: `none = [1,1]` (field + 3 mines;
  `envscales.cfg:8,19,25,31`), `tight = [0.95,1.05]` (grass/grassforest/grasschamomile;
  `:594-612, :623-641, :803`), `wide = [0.85,1.15]` (the other 112 records, **all trees**;
  `:162-164`). Only the tree path is wired; mine/field/stone/bush/stump transforms stay as before.
- Jitter is a deterministic integer position hash (`_hash01`), not RNG, consistent with
  `_pick_sid`'s "No RNG" owner rule. Rendered per-tree scale = base × [0.85, 1.15].
- Not represented: donor `.1.1` envscale extras (`pinesmall1.1` 0.535 at `:272`,
  `pinedry1.1` 0.618 at `:412`, etc.) — no converted mesh carries those entries (open question).

## 5. Mines — what was NOT redone, and why the disc is BLOCKED

- Typed stamping/scale/jitter bypass: **already correct** (DTRN-05 C5, §5.1), explicitly left
  untouched. `_jitter_factor` returns exactly `1.0` for the `"none"` band and is only called for
  `type=="wood"`; no mine motion/VFX was added (DTRN-05 C8: no donor mine sparkle found).
- **BLOCKED** — separate terrain ground-disc art: there is **no** matching deposit-disc asset
  under `variant3d/assets/terrain/**`. That directory contains `decals_png/eurgold.png`,
  `eurcoad.png`, `eurirod.png` — the **built-mine 5×5 dirt plates** (DTRN-05 C14), not the
  deposit's cracked olive/beige disc, plus field/christmas-tree decals and masks. No art was
  invented and no donor pixels were converted.
- Measured finding: the donor disc is **already present in 3D**. `assets/models/tex/mine_gold.png`
  (2048², donor `minegold.dds`) is the full albedo atlas whose low-Z region is the cracked disc
  (DTRN-05 C7); `_default_material()` at `:444-450` loads `TEX_DIR + sid + ".png"` and
  `_mesh_info()`/`_bake_mesh()` apply it to the converted mine OBJ with the donor UVs. The
  "disc stripped" defect in DTRN-05 is the **2D** `_mine_marker_tex` path, not this module.
  Status recorded in `MINE_DISC_STATUS` (`:178`) / stats `:388`.
- Beige `*s` variant trigger remains UNVERIFIED (DTRN-05 §9 Q2).

## 6. UNVERIFIED / OPEN labels

- **UNVERIFIED — authored yaw**: `game.gd:_add_res:509-510` writes only
  `id/kind/type/pos/hits/max_hits/radius` (plus food growth); no `face`/`yaw`/`rot` reaches this
  module, and `pattern_gen.gd` passes none. Res yaw stays exactly 0; no hashed/invented rotation
  was substituted (ticket's explicit fallback). DTRN-04 C10/T4 target is therefore not met.
- **OPEN — forest-stand pass**: the donor's authored stands/per-cell fill/edge clumps (DTRN-04 F3,
  C6–C8) need a decor array distinct from `res_nodes` plus generation changes in `game.gd` and
  `pattern_gen.gd`, both other owners this turn. Reusing only this module's placement data would
  double-count wood nodes (TEST-01 T2 purity) and cannot align to generation without those edits.
- No sway/winter material swap added: both are out of this ticket's minimal scope (winter needs
  `<sid>w.png` assets and a season key not present here).

## 7. Validation — variant runner only

```
python variant3d\tools\godot_runner.py run --id decor01-smoke --timeout 120 -- \
  --headless --path variant3d --script C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/decor01_smoke.gd
```

- Ticket **358**: `START (waited 44.96s)`, `END ok (run 7.22s)`; result
  `variant3d/.godot_queue/results/00000358_decor01-smoke/`.
- stderr `SCRIPT ERROR == 0` (5 lines: only the pre-existing ANIM_STATUS `push_warning` from
  `bind()` at `:390`, unchanged by this ticket).
- stdout:
  `DECOR01_SMOKE_STATS pool=19/19 ladder=18 band=wide mine=0.3152 resources=3`,
  `DECOR01_SMOKE_OK`.
- The probe is an approved-temp `SceneTree` script **outside the repo** (same pattern as CAM_01
  `cam01-smoke`), loading the owned module, binding a duck-typed stub with `height_at`, feeding
  wood/stone/gold nodes and calling `sync(0.0)`. No gate/ladder run, no direct `godot` launch.

### Foreign / pre-existing errors — reported, NOT reverted

- An earlier probe with the existing atom `tests/t_entities3d.gd` (ticket 347, runner `ok`) showed
  one `SCRIPT ERROR: Out of bounds get index '0' (PackedStringArray)` at
  `t_entities3d.gd:97` in `_strip_comments`, triggered by **pre-existing** bare `#` lines at
  `world3d_entities.gd:4,9,12,40,60` (all in the untouched header). It is a harness bug in another
  owner's test file, not caused by DECOR-01; hence the approved-temp probe above.
- `t_terrain_trees.gd:60` and `t_combo_trees_mines.gd:69` still hard-code the old 6-sid
  `POOL_TREE` copy. Those atoms may now report sids outside their stale literal; category names
  and counts are unchanged and the stale copies belong to other owners — not edited here.
- Concurrent foreign modifications visible in `git status` (camera3d.gd, config.gd, hud.gd,
  terrain/water shaders, tests manifest, etc.) were left untouched.

## 8. Open questions

1. Which donor scale governs `tree_oak` (prop `scaleproperty`, pattern `Scaling`, or an absent
   group)? DTRN-04 §9 Q4. Kept at legacy 0.5 pending evidence.
2. Do the donor `.1.1` envscale extras (`0.535`, `0.618`, …) correspond to un-converted mesh
   variants, or to a season/material duplicate? If the former, those sids should be imported by
   an asset owner before they can enter `POOL_TREE`.
3. Does any downstream generator (other owner) intend to attach authored yaw to `res_nodes`?
   If yes, `_xf()` can consume it without changing the scale/jitter code added here.
4. Should a converted RGBA deposit-disc PNG be placed under `assets/terrain/` by an asset owner
   to unblock the separate-apron restoration (DTRN-05 F1)? The 3D mine already shows the donor
   disc through its albedo, so this is a presentation choice, not a stripped asset in 3D.
5. Visual parity remains UNVERIFIED: no donor render was used and no numeric 3D visual gate was
   run (the ticket forbids gates/ladder); only structural/numeric smoke is claimed.

## 9. Files touched

Edited: `variant3d/scripts/world3d_entities.gd` and
`docs/coord_swarm_2026-11-25/reports/DECOR_01_implementation.md` — **no other file**.
Created backup: `inbox/backup/world3d_entities.gd.bak-DECOR01` (required by the ticket).
Temp probe outside the repo: `%TEMP%\opencode\decor01_smoke.gd` (runner artifact only).

*End of DECOR-01.*
