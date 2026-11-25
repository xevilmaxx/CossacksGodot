---
id: PW-01-MATERIAL-MAP
task: "PW-1 — donor winter-prop material name map (79 entries)"
date: 2026-11-25
status: DELIVERED__DATA_ONLY__READ_ONLY_DONOR__NO_ART_COPY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_PARITY_CLAIM
scope: "Only two new files: variant3d/assets/terrain/prop_winter_materials.json and this report. No .gd/.gdshader/.json elsewhere/.png/.dds/config/test/asset/app/** file was written. Donor opened read-only with open(path,'rb').read().decode('latin-1'); never executed, unpacked or copied. No Godot runner job."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/assets/terrain/prop_winter_materials.json"
  - "docs/coord_swarm_2026-11-25/reports/PW_01_material_map.md"
visual_parity_claim: false
labels: [observed, derived, UNVERIFIED]
---

# PW-01 — donor winter-prop material name map

## 1. Donor citations (all fresh reads, this pass)

| # | Source | What was read |
|---|---|---|
| D1 | `C:\Games\Cossacks 3\data\materials\env\env.mat:815-1551` | Whole `// envwinter` block (marker at `:815`; file length 1,552 lines). `Material.Name` and `Material.Texture.image` lines parsed from raw latin-1 bytes, 1-based. |
| D2 | `C:\Games\Cossacks 3\data\materials\env\*.dds` (directory listing) | Every `dds_source` basename was checked to exist on the donor. |
| D3 | `C:\Games\Cossacks 3\data\objects\env\*.prop` (354 files) | Full byte/text read of each file; exact material-name token counted once per file with a word-boundary regex. |
| D4 | `variant3d\assets\**` (8,211 files) | Fresh read-only walk: 0 file stems equal any of the 79 names — 0 case-insensitive, 0 substring matches. |
| P1 | `docs/coord_swarm_2026-11-25/reports/PROP_W_PLAN_01.md:45-164,248-263` | PW-1 specification read in full before work; plan's PW-1 owner path noted in §6 below. |

All cited donor material lines are `env.mat:<name line>`; the bound image line is stored separately
per entry as `donor_image_path_line`. No donor file was copied into the repository.

## 2. Output schema

`variant3d/assets/terrain/prop_winter_materials.json` (UTF-8, 36,024 bytes):

```json
{
  "id": "PW-1-MATERIAL-MAP", "schema_version": 1, "date": "2026-11-25",
  "status": "DATA_ONLY__READ_ONLY_DONOR__NO_ART_COPY__NO_CODE_EDIT__NO_PARITY_CLAIM",
  "source": { "donor_material_block": "…env.mat:815-1551 (// envwinter marker at :815)",
              "donor_dds_root": "…\\data\\materials\\env\\",
              "donor_prop_root": "…\\data\\objects\\env\\", "read_method": "…" },
  "field_definitions": { … }, "counts": { … },
  "labels": ["observed", "derived", "UNVERIFIED"],
  "visual_parity_claim": false, "notes": [ … ],
  "entries": [ { "winter_material_name": "fir1w",
                 "base_name": "fir1",
                 "donor_path_line": "C:\\Games\\Cossacks 3\\data\\materials\\env\\env.mat:817",
                 "donor_image_path_line": "C:\\Games\\Cossacks 3\\data\\materials\\env\\env.mat:818",
                 "dds_source": "fir1w.dds",
                 "is_alias": false, "alias_label": "",
                 "consuming_prop_count": 5, "port_art_exists": false }, … ]
}
```

Per-entry fields (79 objects, in donor `env.mat` order):

| Field | Meaning |
|---|---|
| `winter_material_name` | Exact `Material.Name` ending in lowercase `w` (observed). |
| `base_name` | Deterministic derivation: name with its single trailing `w` removed; **not** a donor field (derived). |
| `donor_path_line` | 1-based `env.mat` line where `Material.Name` is defined (observed). |
| `donor_image_path_line` | 1-based `env.mat` line where `Material.Texture.image` is bound (observed). |
| `dds_source` | Basename of the bound donor DDS, resolved under `donor_dds_root` (observed). |
| `is_alias` | `true` when the DDS stem differs from the material name; the entry reuses existing donor art (derived). |
| `alias_label` | Human-readable `ALIAS — reuses donor DDS …` note for the 7 aliases; `""` for the other 72 (derived). |
| `consuming_prop_count` | Number of the 354 donor `.prop` files containing the exact name token (observed/derived). |
| `port_art_exists` | Always `false` — no port art path is asserted (observed from D4). |

The two files are data-only. `port_art_exists: false` is a statement about the fresh port scan,
not a promise about future art; no `port_texture` path was invented.

## 3. The 7 aliases (reused DDS, labelled)

| Material | `env.mat` name line | `dds_source` (bound at image line) | Consuming props |
|---|---:|---|---:|
| `plantswateratlastransparencyw` | `:1385` | `plantswateratlasw.dds` (`:1386`) | 4 |
| `desert1w` | `:1510` | `desert1.dds` (`:1511`) | 4 |
| `desert2w` | `:1514` | `desert2.dds` (`:1515`) | 4 |
| `desert3w` | `:1518` | `desert3.dds` (`:1519`) | 4 |
| `desert4w` | `:1522` | `desert4.dds` (`:1523`) | 4 |
| `desert5w` | `:1526` | `desert5.dds` (`:1527`) | 4 |
| `desertstumpw` | `:1550` | `desertstump.dds` (`:1551`) | 5 |

(Six reuse an un-suffixed DDS; `plantswateratlastransparencyw` reuses another `w`-suffixed DDS.)

## 4. Counts (fresh, verified twice)

| Metric | Result | Label |
|---|---:|---|
| Winter prop material entries | **79** | observed |
| Same-named DDS (`is_alias: false`) | **72** | derived |
| Aliases (`is_alias: true`) | **7** | derived |
| Distinct DDS sources | **78** | derived (72 same-named + 6 un-suffixed alias DDS; the transparency alias reuses `plantswateratlasw.dds`) |
| Donor `.prop` files scanned | **354** | observed |
| `.prop` files consuming ≥1 `w` name | **321** | observed |
| Names consumed by ≥1 prop | **74** | observed |
| Names never consumed | **5** — `field5w`, `field6w`, `field7w`, `rocksea2w`, `rocksea3w` | observed |
| Port files with any of the 79 stems | **0** (8,211 files walked; 0 exact / 0 case-insensitive / 0 substring) | observed |
| Port art entries set to `true` | **0** | derived |

The `// envwinter` block also contains **9 non-`w` materials** — `decortree1`, `decortree21`,
`decortree22`, `decortree23`, `decortree3`, `pump`, `gift`, `christmastree`, `christmastreea`
(lines `:1432-1500`) — which are seasonal/holiday entries but not winter *prop* `w` names.
They are deliberately excluded from the 79-entry map, matching the PW-1 spec. This is why a raw
`Material.Name` scan of the block yields 88 while the winter `w` map has 79.

## 5. Validation (commands and results)

Temporary scripts lived outside the repo in `%TEMP%\opencode\` (`pw1_scan.py`,
`pw1_build.py`, `pw1_portcheck.py`, `pw1_validate.py`); no runner jobs were created.
Executed with `python` (3.14), e.g.:

```
python "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\pw1_scan.py"
python "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\pw1_portcheck.py"
python "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\pw1_build.py"
python "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\pw1_validate.py"
```

First-pass scan output:

```
env.mat block lines 815-1551, total parsed w materials: 79
duplicate names: []
split: non-alias 72 alias 7
dds missing on donor: []
prop files scanned: 354
props consuming >=1 w name: 321
names consumed: 74
names never consumed: ['field5w', 'field6w', 'field7w', 'rocksea2w', 'rocksea3w']
```

Port check output:

```
port asset files: 8211
exact stems: []
case-insensitive stems: []
substring stems: []
```

Independent validator (fresh donor re-read + fresh prop re-scan, not reusing the first scan's data):

```
PASS JSON parses (utf-8) 36024 bytes
PASS exact 79 entries 79
PASS no duplicate names unique=79
PASS all names end in w
PASS 72/7 split 72/7
PASS required fields on every entry
PASS port_art_exists false everywhere
PASS base_name = name minus trailing w
PASS alias_label only on aliases
PASS alias dds stems differ from name
PASS non-alias dds stems equal name
PASS all counts non-negative ints
PASS every donor_path_line matches fresh env.mat
PASS every dds_source + image line matches fresh env.mat
PASS every dds_source exists on donor
PASS per-name prop counts match fresh rescan
PASS 321 consuming props / 74 names 321 props, 74 names
PASS header counts match entries

SUMMARY: 18/18 checks passed
```

## 6. What was NOT done

- **No donor art was copied** into the repository, nor into any other output path; no donor file
  was executed, unpacked or modified. No DDS/PNG conversion was performed.
- **No code was edited**: no `.gd`, `.gdshader`, config, test, atlas JSON, manifest, model or
  asset file was touched. `app/**` untouched. No Godot runner job was scheduled.
- No art path was invented and **no visual parity is claimed**; conversion permission and donor
  runtime/season behaviour remain UNVERIFIED.
- Repo `git status --porcelain` at task start already showed unrelated pre-existing changes
  from other builders (e.g. `docs/coord_swarm_2026-11-25/PROGRESS.md`, `README.md`,
  `variant3d/tests/results/t_terrain_only.json` and other untracked reports/results).
  Other agents edited more files concurrently; none of those files were read-modified or
  written by this task. The only files authored here are the two declared outputs.

## 7. Open questions (do not guess)

1. **Output path.** `PROP_W_PLAN_01.md:257` names `variant3d/assets/terrain/structs/prop_winter_materials.json`
   as PW-1's owner file, while this task's exclusive-output instruction names
   `variant3d/assets/terrain/prop_winter_materials.json`. The task instruction was followed;
   PW-3's resolver owner should confirm the path before consuming the JSON.
2. **`pinestumpw` discrepancy.** Plan line 74 notes `pinestump.dds` (no `w`); the fresh read at
   `env.mat:1253-1254` binds `pinestumpw.dds`. Both files exist on the donor. The fresh read was
   recorded; whether the plan note described a different revision is UNVERIFIED.
3. **Alias reuse in port.** The 6 un-suffixed DDS aliases and 1 `w`-DDS alias are donor bindings;
   whether any existing port file may legitimately stand in for them is an asset-owner decision
   (Q1/Q6 of PW-PLAN-01), not something this data map decides.
4. **Keying** (`fir1w` material name vs `tree_fir` port sid) remains unresolved (PW-PLAN-01 Q6);
   this JSON keys on the donor material name only.
5. **Non-`w` seasonal entries** (`decortree*`, `pump`, `gift`, `christmastree*`) were excluded as
   out-of-scope; if a later ticket wants them, a separate map decision is required.
6. **Art availability/conversion permission**, emission→screen colour, and donor runtime season
   switching stay UNVERIFIED per PW-PLAN-01 §5.

## 8. Summary

Fresh reads of `C:\Games\Cossacks 3\data\materials\env\env.mat:815-1551` and all 354 donor
`objects\env\*.prop` files produced a **79-entry** winter prop material map: **72** materials with
same-named DDS and **7** explicitly labelled aliases reusing existing donor DDS. **321** prop
files consume **74** of the 79 names; 5 are unreferenced. A fresh walk of 8,211 port asset files
found **0** matching stems, so every entry records `port_art_exists: false`. JSON parses cleanly,
has no duplicates, and passed **18/18** independent validation checks. Only the two declared
output files were written: no donor art was copied and no code was edited.

*End of PW-01. Two verification passes on the headline counts.*
