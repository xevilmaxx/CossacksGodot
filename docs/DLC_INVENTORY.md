# DLC & cinematic donor inventory (private-use, read-only)

Backlog tickets **N-15** (DLC content inventory) and **N-16** (donor cinematics inventory).
Prepared by worker `agentAD` on 2026-11-21.

This is an **inventory only**. Donor files were inspected read-only under
`C:\Games\Cossacks 3`; **no donor file was copied, converted or committed** into
this repository. The donor install is **private use only — never redistribute**.
No Godot was launched and no game code was edited.

## 1. DLC family inventory

Counts are recursive file counts; sizes are exact byte totals (MiB = bytes / 1,048,576).

| DLC family | path (donor, read-only) | file count by extension | total size | ported in Godot? | status | rationale |
|---|---|---|---|---|---|---|
| `dlc1` | `C:\Games\Cossacks 3\dlcs\dlc1` (`data\maps\missions`) | 20 files: `.map` ×10, `.aix` ×10 | 573,394,374 B (546.83 MiB) | **No** — no DLC filename in `app/assets/**` or `app/CREDITS.md` | UNKNOWN | Contents are Polish/Serbian mission maps `polmis1–5`, `scemis1–5` plus 10 compiled `.aix` AI blobs. Closed-binary `.map` format; `extract_map.py` reads only header/placement names (per `app/CREDITS.md`), no public heightmap spec. No unit/building family to port. No waiver decision is recorded for DLC content. |
| `dlc2` | `C:\Games\Cossacks 3\dlcs\dlc2` (`data\maps\missions`) | 13 files: `.map` ×13 | 707,889,596 B (675.10 MiB) | **No** | UNKNOWN | Mission maps `prumis1–5`, `scemis6–8`, `swemis1–5`; no `.aix` files. Same closed-format limitation; no ported asset and no recorded waiver. |
| `dlc3` | `C:\Games\Cossacks 3\dlcs\dlc3` (`data\maps\missions`) | 14 files: `.map` ×10, `.aix` ×4 | 582,925,795 B (555.92 MiB) | **No** | UNKNOWN | Mission maps `spamis1–5`, `turmis1–5` plus 4 `.aix` AI blobs. Same limitation; no ported asset and no recorded waiver. |
| `dlc4` | `C:\Games\Cossacks 3\dlcs\dlc4` (`data\maps\missions`) | 11 files: `.map` ×9, `.aix` ×2 | 798,232,020 B (761.25 MiB) | **No** | UNKNOWN | Mission maps `netmis1–5`, `scemis9–12` plus 2 `.aix`. Largest single donor map here is `netmis1.map` (~136.1 MB). Same limitation; no ported asset and no recorded waiver. |
| `exp1` | `C:\Games\Cossacks 3\dlcs\exp1` (`data\maps\missions`) | 5 files: `.map` ×5 | 285,374,874 B (272.15 MiB) | **No** | UNKNOWN | Expansion mission maps `scomis1–5`; `.map` only, no `.aix`. Same limitation; no ported asset and no recorded waiver. |
| `summer` | `C:\Games\Cossacks 3\dlcs\summer` (`data\maps\missions`) | 2 files: `.map` ×1, `.aix` ×1 | 87,382,209 B (83.33 MiB) | **No** | UNKNOWN | One mission map `celmis2.map` (~83.3 MB) + `celmis2.aix`. Note: `*summer*` names in `app/assets/` are base terrain presets/tints, **not** this DLC. No ported asset and no recorded waiver. |
| `winter` | `C:\Games\Cossacks 3\dlcs\winter` (`data\maps\missions`) | 2 files: `.map` ×1, `.aix` ×1 | 53,988,380 B (51.49 MiB) | **No** | UNKNOWN | One mission map `celmis1.map` (~51.5 MB) + `celmis1.aix`. Note: `winter*.png` in `app/assets/terrain/` are base seasonal terrain tints, **not** this DLC. No ported asset and no recorded waiver. |
| **All 7 DLC families** | `C:\Games\Cossacks 3\dlcs\*` | **67 files total** (`.map` ×49, `.aix` ×18) | **3,089,187,248 B (2,946.08 MiB ≈ 2.88 GiB)** | **No** | **UNKNOWN** | Every DLC contains only closed-format mission maps and tiny compiled AI blobs under `data\maps\missions` — no meshes, textures, sounds or other portable families. No DLC family is ported and none is formally waived; scope is undecided. Per the inventory-only assignment, no DLC unit/building was added and no code was edited. |

## 2. Donor cinematics — `data\video` (N-16)

| Family | path (donor, read-only) | files present | total size | ported in Godot? | status | rationale |
|---|---|---|---|---|---|---|
| Cinematics | `C:\Games\Cossacks 3\data\video` | 1 file: `video.lib` (`.lib`, text manifest, 64 B). **No** `.ogv` / `.avi` / `.mp4` / `.bik` cinematic files present. `FileName = ` is blank; `CanSkip = true`. | 64 B | **No** — no donor video exists under `app/assets/` | **WAIVED** (decision Q4, 2026-11-21, already taken) | `data\video` cinematics are **WAIVED as non-playable** — they have no bearing on the singleplayer skirmish gameplay this port targets. No donor video may be copied, converted or committed. Waiver recorded in `WAIVERS.md` §"Waiver 1"; this inventory does **not** change that decision. The only file in the folder is an empty 64-byte manifest listing no cinematic filenames. |

## 3. "Ported in Godot?" check — method and evidence

Read-only checks performed against the project root:

- `app/assets/` top-level families (recursive file counts): `maps` 5 (all `.json`), `models` 3,955, `sounds` 610 (305 `.ogg` + 305 `.import`), `terrain` 2,332, `ui` 34.
- `app/assets/maps/*.json` contains only `ausmis1.json`, `battle1.json`, `rusmis1.json`, `ukrmis1.json`, `_summary.json`. **None** of the DLC map stems (`polmis*`, `scemis*`, `prumis*`, `swemis*`, `spamis*`, `turmis*`, `netmis*`, `scomis*`, `celmis*`) occur there.
- `app/CREDITS.md` has **0 matches** for `dlc`, `exp1`, `summer`, `winter`, `polmis`, `scemis`, `video`, `ogv`, `cinematic`. It documents only the base `.map` extraction approach (`data/maps/missions/*.map` → `assets/maps/*.json`) for `ausmis1`, `battle1`, `rusmis1`, `ukrmis1`.
- The `summer`/`winter` strings found in `app/.godot/` caches are generated from base seasonal terrain textures (e.g. `winter*.png`) and preset JSONs — they are a different family from the `dlcs/summer` and `dlcs/winter` DLC directories.

## 4. Open questions

- The 7 DLC families are unported and **not** covered by any waiver decision in `WAIVERS.md` (which contains only the `data/video` and withdrawn naval waivers). Should the coordinator formally waive DLC mission maps as non-playable/closed-format, or leave them UNKNOWN pending a scope ticket? This inventory deliberately records **UNKNOWN** and created **no new waiver**.
- DLC `.map` files share the closed binary format of the base maps that `extract_map.py` can only partially read. Any future DLC-mission port would need a format reader or a procedural mimic; not attempted here (inventory-only, no code edits).
- The 18 `.aix` compiled AI blobs were counted by extension/size only, not decoded — out of scope for this read-only inventory.

## 5. Compliance

No donor asset is redistributed. All donor paths above point to the locally installed game at `C:\Games\Cossacks 3` on the owner's own computer. Nothing was downloaded, uploaded, published or shared. See `WAIVERS.md` and `SWARM_OPS.md` §3.5.
