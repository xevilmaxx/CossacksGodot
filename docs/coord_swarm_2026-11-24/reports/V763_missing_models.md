---
id: V7-63
owner: V7-63
scope: "variant3d/ only: extend tools/convert_models.py to convert the missing unit/building donor meshes; regenerate OBJ/MTL/PNG + manifest; measure roster coverage"
date: 2026-11-24
status: DELIVERED__APPROXIMATION_LABELLED
mode: "donor read-only; no .gd / app/ / config / test edited; no git; no Godot; staging outside repo, only new OBJ/MTL/PNG + appended manifest entries written under variant3d/"
---

# V7-63 — Missing donor models: converter coverage 58 -> 2

## 1. Task and baseline

AUDIT3D-01 evidence #13 (`docs/coord_swarm_2026-11-24/reports/AUDIT3D_01_models.md:67,93-110`)
measured **81 unit/building IDs in `variant3d/scripts/data.gd:581-1302`** (62 units,
19 buildings) and only **23 with an OBJ**; the other **58** fell back to the
invented 1 m cube in `world3d_entities.gd:191-213,277-282`. The audit's P0-2
smallest fix is exactly this ticket: extend the hardcoded tables in
`variant3d/tools/convert_models.py:160-221` with donor files already verified
present.

Baseline re-measured from the checked-in manifest before any edit:

| Metric | Before |
|---|---|
| Manifest entries | 116 (9 unit / 14 building / 93 env) |
| OBJ files on disk under `variant3d/assets/models/obj/` | 116 |
| Roster IDs covered (units + buildings) | **23 / 81** |
| Roster IDs missing (cube fallback) | **58** |

## 2. How the donor source paths were obtained (read-only)

No donor file was modified or executed. Every mapping below comes from a
**text** source in the port or the donor, then every named binary was opened
read-only with the converter's own `read_oss` / `read_osm` to prove it parses.

| Evidence | What it supplies |
|---|---|
| `app/tools/bake_sprites.py:664-674` | sid -> exact donor `.oss` base for 46 of the missing units (e.g. `musk18 -> musketeer18`, `dragoon17 -> dragoon`, `pope -> pope`, `framegun -> framegun`) |
| `app/tools/bake_scottish.py:52-53` | `sco_highlandersword -> swordsmansco` (the one Scottish unit absent from the main bake table) |
| `app/tools/bake_naval.py:43-54` | seven ship bases (`yacht, yachttur, fishboat, frigate, galley, battleship, xebec`); `:44-45,52-53` state battleship/xebec have **no** animated `.oss` and need the static `.osm` path — used here for **all seven** hulls (the `.oss` on the others is the crew figure, not the hull) |
| `app/tools/bake_sprites.py:657` | building suffix mapping `ba2 -> bar18`, `dip -> dip` |
| donor `data/actors/actors.lib:475` | `ukrdip` actor (matches `dip`) |
| donor `data/actors/actors.lib:543,657` | `// walls` section, `eurswa` (stone wall) and `eurswa_gate` (gate) actors, matching `wal` / `gat` |
| donor filesystem (read-only enumeration) | all 56 `.oss`/`.osm` meshes and all 56 same-named `.dds` albedos present; see §5 |

The two IDs **not** mapped are documented in §6 — no geometry was guessed to
close them.

## 3. Exact converter diff (`variant3d/tools/convert_models.py` only)

No other source file was edited. `app/tools/convert_models.py` was **not**
touched (it remains byte-identical to its previous state).

| File:line | Change |
|---|---|
| `:21-24` | Added docstring note: outputs are **static bind poses**; `.oss` weights/bones/frames and `.osm` later frames are discarded; every mesh is a **PORT APPROXIMATION, not donor animation parity**; 3D renderer must keep its static label. |
| `:180-186` | Comment: mapping source and rule — exact donor `.oss` base + same-named DDS from `app/tools/bake_sprites.py:664-674` / `app/tools/bake_scottish.py:52-53`; donor names preserved verbatim for `musk18`, `dragoon17`, `sco_highlandersword`; no shape invented — all read by `read_oss`. |
| `:187-234` | `table.update({...})` in `unit_models()`: **46** new sid -> donor `.oss` base pairs (trainable, nation-variety, Scottish, framegun). |
| `:265-275` | `table.update({...})` in `building_models()`: `dip -> ukr/dip`, `wal -> commoneur/eurswa`, `gat -> commonrus/eurswa_gate` (albedo `commonrus/eurswa.dds`). |
| `:276-280` | Comment recording the deliberate non-mappings `bar18` and `dock` and the exact absent donor candidates (do not guess). |
| `:300-325` | **New** `ship_models(game)`: seven naval sids, `.osm` hull under `data/actors/units`, DDS under `data/materials/units`, `kind="unit"` so the existing opaque-texture policy applies. |
| `:431-432` | `main()` model list changed from `unit_models + building_models + env_models` to `unit_models + building_models + ship_models + env_models`. |

Readers/writers (`read_oss`, `read_osm`, `write_obj`, `write_mtl`,
`convert_texture`) are unchanged: each new OBJ is a byte-for-byte translation
of the donor vertex/UV/face arrays with a bbox computed by the existing code.
No procedural box, billboard or image is generated.

## 4. Commands used

```powershell
# read-only donor probe of every candidate sid (uses the converter's own readers)
python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v763_probe.py

# converter run into a staging dir OUTSIDE the repo (never onto the hardlinked assets)
python "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tools\convert_models.py" \
  --game "C:\Games\Cossacks 3" \
  --out  "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v763_out"

python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v763_verify.py   # counts + hash compare
python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v763_integrate.py  # copy 56 sets, append manifest
```

Donor/preservation checks also used read-only PowerShell: `Get-ChildItem`,
`Get-Item`, `Select-String`, `Get-FileHash`, `fsutil hardlink list`.

**Hardlink safety.** `fsutil hardlink list` proved
`app/assets/models/manifest.json` and `variant3d/assets/models/manifest.json`
are the same inode. The converter was therefore run into a temp staging root;
only the 168 **new** OBJ/MTL/PNG files were copied into `variant3d/`. The
manifest was replaced with `os.replace` (new inode), so the app-side hardlink
keeps its old 116-entry file. Measured after integration: app manifest SHA-256
unchanged (`29F68F1E…`), app `obj/` count unchanged at 348, app `tex/` unchanged
at 232.

## 5. Measured before / after

| Metric | Before | After |
|---|---|---|
| Manifest entries | 116 | **172** (62 unit / 17 building / 93 env) |
| OBJ files on disk (`variant3d/assets/models/obj/`) | 116 | **172** |
| MTL files | 116 | **172** |
| PNG textures | 116 | **172** |
| Roster IDs covered | 23 / 81 | **79 / 81** |
| Missing roster IDs | 58 | **2** (`bar18`, `dock`) |
| Newly converted sids | — | **56** (53 units + 3 buildings) |
| New OBJ/MTL/PNG files | — | 56 / 56 / 56 = **168** |
| `obj/` dir total files (incl. 116 existing `.import`) | 348 | 460 (exactly +112 = 56 OBJ + 56 MTL; **0** new `.import`) |

**Original 116 preserved:** all **348** pre-existing files (116 OBJ + 116 MTL
+ 116 PNG) are **byte-identical** to freshly regenerated copies — 348 equal,
0 differing, 0 absent. The original 116 manifest entries were copied verbatim
into the new manifest; only 56 entries were appended. Every one of the 172
manifest sids resolves to an OBJ on disk.

Sample new meshes (vertex/face counts read from the emitted OBJ, matching the
donor probe): `officer18` 1021/1185, `musk18` 809/1074, `framegun` 607/391,
`yacht` 9364/7731, `frigate` 19008/15205, `dip` 9881/7471, `wal` 4800/3202,
`gat` 4530/2848.

### New sid -> donor source (all under `C:\Games\Cossacks 3`)

Units — mesh `data\actors\units\<base>.oss`, texture `data\materials\units\<base>.dds`:

```
officer18=officer18 drummer=drummer priest=priest grenadier=grenadier
musk18=musketeer18 howitzer=howitzer mortar=mortar musketeer=musketeer
strelet=strelet pikeman18=pikeman18 dragoon17=dragoon hussar=hussar
wingedhussar=wingedhussar cuirassier=cuirassier reiter=reiter
lightcavalry=lightcavalry lightinfantry=lightinfantry tatar=tatar sipahi=sipahi
jannisary=jannisary spakh=spakh mameluke=mameluke vityaz=vityaz hetman=hetman
croat=croat pandur=pandur chasseur=chasseur highlander=highlander pope=pope
padre=padre mullah=mullah drummer18=drummer18 multicannon=multicannon
cossackdon=cossackdon hackapell=hackapell cossackregister=cossackregister
bagpiper=bagpiper sco_highlandersword=swordsmansco pikemansco=pikemansco
swordsmansco=swordsmansco musketeersco=musketeersco archersco=archersco
officersco=officersco lancersco=lancersco raidersco=raidersco framegun=framegun
```

Ships — mesh `data\actors\units\<base>.osm`, texture `data\materials\units\<base>.dds`:

```
yacht fishboat yachttur galley frigate xebec battleship   (base = sid)
```

Buildings (exact paths):

```
dip  data\actors\buildings\ukr\ukrdip.osm          + data\materials\buildings\ukr\ukrdip.dds
wal  data\actors\buildings\commoneur\eurswa.osm    + data\materials\buildings\commonrus\eurswa.dds
gat  data\actors\buildings\commonrus\eurswa_gate.osm + data\materials\buildings\commonrus\eurswa.dds
```

## 6. Still missing (2) — exact donor reasons

| Port sid | Reason | Evidence |
|---|---|---|
| `bar18` | **absent** — no matching donor actor. The port's 2D building table names donor suffix `ba2` (`app/tools/bake_sprites.py:657`); its candidate list `ukrba2` / `eurba2` / `turba2` was checked on disk and **none exists** (17 other nations have `<nat>ba2`, but not Ukraine or the common folders). Donor `actors.lib` has no `ukrba2` / `eurba2` / `turba2` entry. No guess was made: a same-suffix mesh of a different nation would not be donor-faithful for the Ukrainian roster. | `app/tools/bake_sprites.py:657`; donor `actors.lib` `ba2` entries; read-only filesystem enumeration |
| `dock` | **absent** — no shipyard/dock `.osm` actor exists anywhere under `data/actors`. A recursive search for `ship|dock|port|pier|wharf|yard|naval|berth|slip|water` found only `portem` (Portugal market) and environmental `shipwreck*`, neither a shipyard. `"Shipyard"` at `data/locale/en/units.txt:975` is a **label**, not an actor. The 2D port has no dock sprite either (AUDIT3D-01 #15). | donor `actors.lib`, recursive donor actor enumeration, `data/locale/en/units.txt:975` |

No ID is reported UNREADABLE: every donor candidate that exists parsed with
the converter's readers. UNREADABLE would mean a file exists but the decoder
fails — that did not occur.

## 7. 2D bake / sprite-sheet non-production

Confirmed. The converter writes only `obj/<sid>.obj`, `obj/<sid>.mtl`,
`tex/<sid>.png` and `manifest.json` (`write_obj` `:109-125`, `write_mtl`
`:128-133`, `convert_texture` `:135-153`, `main` `:361-372`). Staging root
contained exactly `obj/`, `tex/`, `manifest.json` — no `anim/`, `sprites/`,
`sprites_hi/`, `.png` sheets or `index.json`. Integration copied only OBJ/MTL/PNG
into `variant3d/assets/models/{obj,tex}/`; the pre-existing 2D bake trees
(`anim` 3706 files, `sprites` 359, `sprites_hi` 181) were not written to.
No Blender, no `bake_*.py`, no Godot run.

## 8. Animation / parity label

**No donor animation parity is claimed.** `read_oss` still discards weights,
bones and all animation tracks, and `read_osm` keeps only the first frame; all
56 new OBJs are **static bind poses / PORT APPROXIMATIONS**, exactly like the
original 116. This ticket adds static donor geometry only — it does not change
`anim3d.gd`, does not add morph targets and does not alter the renderer's
explicit "static bind pose, NOT donor-faithful" label.

## 9. Open questions

1. **Godot import not run.** The 56 new OBJs have no `<sid>.obj.import` or
   imported `.mesh` cache (`0` new `.import` files measured). `world3d_entities.gd:112-115`
   counts availability with `ResourceLoader.exists()`, so runtime
   `obj_available` will not include the new sids until a Godot editor import is
   run through `variant3d/tools/godot_runner.py`. Import/verification is left to
   the integration owner (outside this ticket's exclusive file ownership).
2. **`bar18` nation choice.** If a coordinator accepts a non-Ukrainian
   `<nat>ba2` actor as the port's 18th-century barracks, `bar18` can be mapped
   in a follow-up; this ticket deliberately did not guess (AUDIT3D-01 open
   question 3).
3. **`dock` visual.** The port's shipyard is currently an unmatched
   port-authored concept; either a donor actor must be identified from a
   non-English locale or a port-authored visual must be explicitly accepted
   (and labelled as such).
4. **P0-1 unaffected.** This ticket does not make production code call
   `add_unit`/`add_building` (AUDIT3D-01 P0-1): the meshes exist, but wiring the
   live sim to the entity module is a separate integration ticket.
