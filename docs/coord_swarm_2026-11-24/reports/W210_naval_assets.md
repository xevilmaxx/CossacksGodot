---
owner: W2-10
decision: D-22
date: 2026-11-24
gap: G-N1 (R09_naval.md)
scope: navals assets + index.json only; data.gd HAND-OFF for W2-2
mode: observed via Python/PIL + read-only donor latin-1 text; no donor binary copied, no Godot job, no full gate
status: INDEX DONE / DATA.GD HAND-OFF OPEN
---

# W2-10 — Naval staged families + orphan hulls

## 0. Path reality (verify before reading the charter shorthand)

Charter/ownership says `app/assets/models/anim/naval/**` + `anim/naval/index.json`.
**That literal path does not exist.** `observed` 2026-11-24:

| Path (relative to `app/assets/models/anim/`) | Exists | Contents |
|---|---|---|
| `naval/` | **False** | — |
| `naval_units/` | True | `index.json` only (no PNGs) |
| `common/naval/` | True | 12 baked PNG + 12 `.png.import` |

Live renderer path is `res://assets/models/anim/naval_units/index.json`
(`app/scripts/world.gd:185`, `_naval_info`), hull sheets via `common/naval`
(`world.gd:3095-3107`, `_hull_tex`). R09 claim #4 already flags the stale docs.
I edited the **live** `naval_units/index.json`; no `.gd` file was touched.

## 1. Verified inventory (pre-fix vs post-fix)

`python` + PIL, all sizes in bytes. `staging_manifest.json` holds 7 families;
pre-fix `index.json` held 5 keys; `data.gd:1040-1049` had only `yacht`;
`data.gd:1105` `"dock".trains == ["yacht"]`.

| Family | index key pre | key after | PNG in `common/naval/` (bytes) | staging manifest key | data.gd sid pre | Verdict pre-fix |
|---|---|---|---|---|---|---|
| yacht | yes | yes | `yacht_walk.png` 313630; `yacht_hull.png` 68206 | yes | **yes** | wired, complete |
| yachttur | yes | yes | `yachttur_walk.png` 315316; `yachttur_hull.png` 70371 | yes | no | staged-unwired (data.gd only) |
| fishboat | yes | yes | `fishboat_walk.png` 296573; `fishboat_hull.png` 79180 | yes | no | staged-unwired (data.gd only) |
| frigate | yes | yes | `frigate_walk.png` 315961; `frigate_hull.png` 84784 | yes | no | staged-unwired (data.gd only) |
| galley | yes | yes | `galley_walk.png` 310579; `galley_hull.png` 71490 | yes | no | staged-unwired (data.gd only) |
| battleship | **no** | **added** | `battleship_hull.png` 120940 (no walk — donor has no `.oss`) | yes | no | **orphan PNG** → yacht hull fallback |
| xebec | **no** | **added** | `xebec_hull.png` 98175 (no walk — donor has no `.oss`) | yes | no | **orphan PNG** → yacht hull fallback |

Counts: pre-fix 5 index keys ↔ 10 of 12 PNGs referenced, 2 orphans.
Post-fix 7 keys ↔ **all 12** PNGs referenced, **0 orphans**, 0 fallback.
Staging area `app/shots/unit_pieces/naval/` also holds 12 same-named PNGs
(with different sizes; e.g. `battleship_hull.png` 123501, `xebec_hull.png` 100207),
plus `staging_manifest.json` 5100 B and `donor_truth.json` 55263 B. It is a
staging copy, not a renderer source; left untouched.

Donor truth read from `donor_truth.json`: all 7 keys present; 5 crew families
have a 311-frame/20-bone/584-vert `.oss` + `.aaf` walk range 1..280; `battleship`
and `xebec` have `"crew": {"oss": null, "note": "no animated .oss in donor"}`
(`:1913`, and the xebec/battleship blocks at `:1908-`). This confirms the two
new keys must be **hull-only**, exactly as the staging manifest declares.

## 2. Index edit (exact diff)

Backup first: `inbox/backup/naval_index.json.bak-W210` (3450 B, byte copy).
`json.load` passes; all 5 old keys verified **byte-for-byte unchanged**
(`new[:len(old)-2] == old[:len(old)-2]` and every old key's parsed value equal).
Size 3450 → 4198 B. No key invented: each new key has a matching
`common/naval/<key>_hull.png` + `.import` and a `staging_manifest.json` entry.

The two new metric blocks were copied from the staging manifest, which was
**independently re-measured** from the actual staged PNG (PIL, `alpha > 8`,
cell-local union over all 8 cells): `battleship` → `[16,28,144,152]`,
`fig_h 0.775`, `foot 0.95`, `cx 0.5`; `xebec` → `[8,14,151,149]`,
`fig_h 0.8438`, `foot 0.9313`, `cx 0.4969`. Both matched the manifest exactly.
Manifest-only fields `camera_group` and `clip` were dropped; the live schema
(`frames, duration, loop, ortho, center, ax, ay, tool, bbox, fig_h, foot, cx`)
was preserved.

```diff
--- index.json.bak-W210
+++ index.json
@@ -254,4 +254,60 @@
    }
   }
+ },
+ "battleship": {
+  "cell": 160,
+  "actions": {
+   "hull": {
+    "frames": 1,
+    "duration": 1.0,
+    "loop": false,
+    "ortho": 19.311,
+    "center": [
+     -0.008,
+     -0.261,
+     4.985
+    ],
+    "ax": 0.5135,
+    "ay": 0.8896,
+    "tool": null,
+    "bbox": [
+     16,
+     28,
+     144,
+     152
+    ],
+    "fig_h": 0.775,
+    "foot": 0.95,
+    "cx": 0.5
+   }
+  }
+ },
+ "xebec": {
+  "cell": 160,
+  "actions": {
+   "hull": {
+    "frames": 1,
+    "duration": 1.0,
+    "loop": false,
+    "ortho": 15.52,
+    "center": [
+     -0.116,
+     -0.76,
+     5.062
+    ],
+    "ax": 0.5489,
+    "ay": 0.9988,
+    "tool": null,
+    "bbox": [
+     8,
+     14,
+     151,
+     149
+    ],
+    "fig_h": 0.8438,
+    "foot": 0.9313,
+    "cx": 0.4969
+   }
+  }
  }
 }
```

Render consequence (`observed`, `world.gd:3122-3138`): `_draw_naval_hull` used
to take the `info.is_empty() → key = "yacht"` branch for these two sids; now
`info` is non-empty and `_hull_tex("battleship"/"xebec")` resolves their own
PNG. `_draw_anim` (`world.gd:532-555`) finds no `walk`/`idle` action for these
two keys and returns `false`, so they draw **hull only** with no crew sprite —
this is the donor-faithful outcome (no `.oss` exists). The other four staged
families already have both keys and both sheets; they need only data.gd sids.

## 3. HAND-OFF to W2-2 — `app/scripts/data.gd` sids

I did **not** edit `data.gd`. Owner: W2-2. Coordinator integrates after that
worker closes. `UNITS_BASE` ends at `data.gd:1050`; `BUILDINGS_BASE.dock.trains`
is `data.gd:1105`. Add six entries inside `UNITS_BASE` (yacht already exists)
and extend `dock.trains` to 7 sids, otherwise `train_unit()` cannot spawn them
(R09 claim #3).

### 3.1 Donor facts (read-only, latin-1; exact literals)

All from `C:\Games\Cossacks 3\data\scripts\lib\unit.script` unless noted.
Signature `SetObjBasePrice(objbase, food, wood, stone, gold, iron, coal)` and
`SetObjBaseWeapon(objprop, objbase, index, damage, pause, radiusmin, radiusmax,
detectradiusmin, detectradiusmax, kind, bSearchMinAttackRadius)` were read from
the procedure declarations in that same file.

| sid | hp (line) | price = wood/gold/iron/coal (line) | gold upkeep (line) | weapon(s): dmg / pause px-range / iron+coal per shot (line) | localization |
|---|---|---|---|---|---|
| fishboat | 300 (`:1856`) | 600/0/0/0 (`:1862`) | none; `bnohungry` (`:1868`) | none; "Only used for fishing. Cannot take part in battles." | `data/locale/en/units.txt:777-780` |
| yacht (existing) | 31000 (`:1874`) | 900/450/150/200 (`:1886`) | 50 (`:1890`) | 1000 / 350 / 300–1100 / 4+9 (`:1880-1883`), splash 32 px (`:1884`) | `:781-788` |
| yachttur | 35000 (`:1905`) | inherits yacht 900/450/150/200 (no override in `:1903-1920`) | **1500** (`:1919`) | slot0 30 / 400 / default–1000 / 5+15 (`:1909-1911`); slot1 0 / 700 / 1000–1650 / 5+15 (`:1913-1916`) | `:789-793` "Yacht" |
| galley | 35000 (`:1923`) | 9500/900/800/0 (`:1943`) | 1000 (`:1946`) | cannonball 100 / 150 / 300–1200 / 4+9 (`:1930-1933`); mortarball 1000 / 50 / 1100–3100 / 4+9 (`:1935-1938`) | `:794-803` (dual artillery, "When out of gold, the galley stops firing" at `:802`) |
| frigate | 50000 (`:1960`) | 5000/1100/600/800 (`:1972`) | 150 (`:1975`) | 1800 / 75 / 400–1650 / 25+35 (`:1966-1969`) | `:804-809` "Requires funding" |
| xebec | 65000 (`:1990`) | 7000/1600/320/960 (`:1994`) | **0** (`:1996`) | inherits 1800 (`:1993` uses `default`); 50 / 550–1700; iron+coal inherited 25+35 (`:1968-1969`) | `:823-828` "Requires no gold for upkeep" |
| battleship | 90000 (`:1999`), shield 100 (`:2000`) | 9000/3200/700/6500 (`:2006`) | **15000** (`:2008`) | inherits 1800 (`:2003` `default`); 20 / 600–1950 / 5+15 (`:2004-2005`) | `:810-817` "Ship of the Line", "Requires a lot gold" |

`bturnoff` is set for yacht (`:1894`) and the shared frigate/xebec/battleship
block (`:1979`), **not** for galley in the script even though `units.txt:802`
says it stops firing. That contradiction is W2-1's gold-shortage gap (R09 #2),
not mine.

### 3.2 Proposed `UNITS_BASE` entries (ready to paste; read the flags)

Policy used: donor-exact `hp`, `price`, `eat` and weapon damage/range/per-shot
cost; port conventions `PX_TO_M := 1/26.6666666` (`data.gd:22`), `cd = pause *
0.03125`, `build_time = donor buildtime * 0.03125`, and **estimated**
`speed`/`score`/`aiforce`/`prot`/`radius`/`icon` carried over from the yacht
entry (`data.gd:1040-1049`) because the donor does not expose comparable port
values. `derived`/`inferred` flags below are explicit — nothing here is claimed
as donor-verbatim beyond §3.1.

```gdscript
	# G-N1 (W2-10 hand-off): donor-evidenced hp/price/upkeep/weapons;
	# speed/score/aiforce/prot/radius/icon and cd conversion are PORT ESTIMATES.
	"fishboat": {
		"hp": 300, "speed": 2.4, "score": 50, "aiforce": 4, "naval": true,
		"price": {"wood": 600}, "build_time": 1280 * 0.03125, "search": 1280 * PX_TO_M,
		"weapons": [],
		"prot": [1, 1, 2, 30, 3, 20],
		"radius": 1.0,
		"icon": Rect2(322, 368, 46, 46),
	},
	"yachttur": {
		"hp": 35000, "speed": 2.6, "score": 200, "aiforce": 14, "naval": true,
		"price": {"wood": 900, "gold": 450, "iron": 150, "coal": 200},
		"build_time": 1536 * 0.03125, "search": 1050 * PX_TO_M,
		"eat": {"gold": 1500},
		"weapons": [{"kind": "cannonball", "dmg": 30, "min": 300 * PX_TO_M, "max": 1000 * PX_TO_M,
			"cd": 400 * 0.03125, "cost": {"iron": 5, "coal": 15}, "splash": 32 * PX_TO_M}],
		"prot": [2, 2, 4, 60, 6, 45],
		"radius": 1.8,
		"icon": Rect2(322, 368, 46, 46),
	},
	"galley": {
		"hp": 35000, "speed": 2.5, "score": 200, "aiforce": 14, "naval": true,
		"price": {"wood": 9500, "gold": 900, "iron": 800},
		"build_time": 1600 * 0.03125, "search": 1100 * PX_TO_M,
		"eat": {"gold": 1000},
		"weapons": [
			{"kind": "cannonball", "dmg": 100, "min": 300 * PX_TO_M, "max": 1200 * PX_TO_M,
				"cd": 150 * 0.03125, "cost": {"iron": 4, "coal": 9}, "splash": 32 * PX_TO_M},
			{"kind": "cannonball", "dmg": 1000, "min": 1100 * PX_TO_M, "max": 3100 * PX_TO_M,
				"cd": 50 * 0.03125, "cost": {"iron": 4, "coal": 9}, "splash": 32 * PX_TO_M},
		],
		"prot": [2, 2, 4, 60, 6, 45],
		"radius": 1.8,
		"icon": Rect2(322, 368, 46, 46),
	},
	"frigate": {
		"hp": 50000, "speed": 2.7, "score": 300, "aiforce": 20, "naval": true,
		"price": {"wood": 5000, "gold": 1100, "iron": 600, "coal": 800},
		"build_time": 7360 * 0.03125, "search": 1800 * PX_TO_M,
		"eat": {"gold": 150},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 400 * PX_TO_M, "max": 1650 * PX_TO_M,
			"cd": 75 * 0.03125, "cost": {"iron": 25, "coal": 35}, "splash": 32 * PX_TO_M}],
		"prot": [3, 3, 6, 80, 8, 60],
		"radius": 2.2,
		"icon": Rect2(322, 368, 46, 46),
	},
	"xebec": {
		"hp": 65000, "speed": 2.9, "score": 300, "aiforce": 20, "naval": true,
		"price": {"wood": 7000, "gold": 1600, "iron": 320, "coal": 960},
		"build_time": 7360 * 0.03125, "search": 1800 * PX_TO_M,
		"eat": {"gold": 0},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 550 * PX_TO_M, "max": 1700 * PX_TO_M,
			"cd": 50 * 0.03125, "cost": {"iron": 25, "coal": 35}, "splash": 32 * PX_TO_M}],
		"prot": [3, 3, 6, 80, 8, 60],
		"radius": 2.2,
		"icon": Rect2(322, 368, 46, 46),
	},
	"battleship": {
		"hp": 90000, "speed": 2.2, "score": 500, "aiforce": 32, "naval": true,
		"price": {"wood": 9000, "gold": 3200, "iron": 700, "coal": 6500},
		"build_time": 12480 * 0.03125, "search": 1680 * PX_TO_M,
		"eat": {"gold": 15000},
		"weapons": [{"kind": "cannonball", "dmg": 1800, "min": 600 * PX_TO_M, "max": 1950 * PX_TO_M,
			"cd": 20 * 0.03125, "cost": {"iron": 5, "coal": 15}, "splash": 32 * PX_TO_M}],
		"prot": [4, 4, 8, 100, 10, 80],
		"radius": 2.6,
		"icon": Rect2(322, 368, 46, 46),
	},
```

`dock.trains` at `data.gd:1105` →
`"trains": ["fishboat", "yacht", "yachttur", "galley", "frigate", "xebec", "battleship"],`
(order is donor tier: fisher/low → mid → ship-of-the-line; R09 asks for ≥7
sids). `fishboat` must also be a valid training sid even though it cannot
fight; its asset pair exists.

**Inference caveats W2-2 must arbitrate:**

- `hp` donor-exact (31000/35000/…/90000) clashes with the existing estimated
  yacht `hp: 900` (`data.gd:1041`) by ~34×. R09 #9 recommends keeping the
  declared estimate. Either rescale all seven together or leave the six new
  entries at estimates; do not mix silently.
- The galley second donor weapon is `mortarball` (`:1935`); the port has no
  such weapon kind (`game.gd:297`, `:4839-4844` handle `cannonball` and
  `cannister` only), so I proposed a long-range `cannonball` with the donor
  damage/range. True bombard behaviour needs `game.gd` (W2-1); this is R09 #13.
- Donor `dmg` for battleship/xebec is `default` (`:1993`, `:2003`), i.e.
  inherited 1800 from the shared block (`:1966`). `derived`, not literal.
- `build_time` for yachttur uses the shared 1536 (`unit.script:1888`); its own
  block overrides buildtime to `default{300}` (`:1918`, with a comment that
  construction speed was reduced 10×). `derived` choice — W2-2 may prefer 300.
- `eat.gold` values are donor `consume` per unit, but the port's upkeep cadence
  may differ (R09 #7/#9); W2-1 and W2-2 should agree before enabling
  `battleship` at 15000.
- `icon: Rect2(322,368,46,46)` is copied from yacht for all six — a placeholder,
  not a per-ship donor UI rect. Use a distinct rect if the UI atlas has one.

## 4. Open questions / follow-ups (not fixed here)

1. **Stale framing in the 5 pre-existing index keys.** Pre-fix `index.json`
   gives *all five* hull actions `ortho 11.355`, `center [0,-0.805,3.214]`,
   `ax 0.5709`, `ay 0.9267` — copied from yacht — while `staging_manifest.json`
   and the actual PNGs have per-family values: yachttur 10.775/[0,-0.391,2.651]/0.5363/0.8709, fishboat 4.6/[-0,0.019,1.197]/0.4958/0.8926, frigate 19.435/[0,0.064,5.468]/0.4967/0.9241, galley 14.825/[0.019,0.346,3.534]/0.4767/0.8582. `bbox/fig_h/foot/cx` were measured per family, so the PNGs are fine; only world-anchor fields are stale. `world.gd:3135-3138` scales/anchors hull by `ortho/ax/ay`, so those four ships will render at yacht scale once spawned. I preserved them byte-for-byte as instructed; this needs a separate owner decision (W2-5 or a follow-up asset lane).
2. **Hull-only entities.** `battleship`/`xebec` now spawn with a hull and no crew. Acceptable per donor (no `.oss`), but R09 #6 asks for an explicit product decision; if a crew must be synthesised, that is a new bake, not an index edit.
3. **Extended naval families.** Donor also has `chaika` and `ferry` (70 meshes total vs 54 core). Neither has a baked PNG, so I invented no keys (per task). If wanted, they need a bake before an index key.
4. **Docs paths.** `STATUS_GRAPHICS.md:68,130`, `NAVAL_PORT_PLAN.md:34`, `SWARM_BOARD.md:663` still say `anim/naval/index.json` and "54/1 keys"; live is `naval_units/index.json` with 7 keys. R09 #4 assigned this to doc owners, not me.
5. **Tests.** `app/tests/t_naval.gd:22` still uses `OWNER = "yacht"`; `results/t_naval.json` covers 6 checks on one family. After W2-2 integrates the sids, parameterise the test over all 7 index keys and assert 0 orphans/0 fallback (R09 #16). I did not edit tests.

## 5. Verification performed

- `python -c "import json; json.load(open(...))"` → parse OK, 7 keys.
- Old 5 keys byte-identical to `inbox/backup/naval_index.json.bak-W210`.
- PNG alpha metrics re-measured for both new keys (PIL, `alpha > 8`, cell-local) → exact match with staged manifest.
- `git status --short` before edit: index.json clean; after edit only that file + this report are mine.
- No donor binary copied or executed; donor text read with `encoding='latin-1'`, read-only.
- No Godot job (asset/index-only); no full gate. Coordinator runs the final gate.
