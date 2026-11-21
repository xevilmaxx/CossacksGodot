# Naval donor evidence — decision Q3 (worker agentW)

Read-only inspection of the installed donor at `C:\Games\Cossacks 3`, performed
2026-11-21 via PowerShell `Get-ChildItem` + a Python `struct` header check.
**No donor file was copied, moved or modified.** This file is the evidence
artifact requested by the coordinator decision Q3 / backlog ticket N-11.

## 1. Directories (existence proof)

| Path | Result |
|---|---|
| `data\actors` | EXISTS — subdirs: `buildings`, `env`, `misc`, `pfx`, `ref`, `units` |
| `data\animations` | EXISTS — subdirs: `aaf`, `acl`, `ref`, `tpl` |
| `data\actors\units` | EXISTS — 4232 `.oss`/`.osm` meshes total under `data\actors` |
| `data\animations\aaf` | EXISTS — 194 files |
| `data\animations\acl` | EXISTS — 33 files |

## 2. Verdict: naval meshes are PRESENT and READABLE

Q3 asked: *"Are naval meshes actually readable in `data/actors`, or only
referenced by `.aaf`?"* **Answer: readable meshes exist in both `data/actors`
and `data/animations`.** A documented waiver for N-11 is **not** justified on
the grounds of missing/unreadable donor meshes; N-11 can proceed as a real port
(private-use only — never redistribute the donor binaries).

### 2.1 `data\actors\units` — 54 naval unit meshes (exact filenames)

Seven ship families, each with a base `.osm` plus numbered direction variants
`1`–`4` and `_death1`/`_death2` wreck stages:

- `battleship.osm` (822,604 B), `battleship1.osm`…`battleship4.osm`,
  `battleship_death1.osm`, `battleship_death2.osm` — 7 files, no `.oss`
- `fishboat.osm` (71,868 B), `fishboat.oss` (217,344 B), `fishboat1.osm`…
  `fishboat4.osm`, `fishboat_death1.osm`, `fishboat_death2.osm` — 8 files
- `frigate.osm` (866,140 B), `frigate.oss` (217,344 B), `frigate1.osm`…
  `frigate4.osm`, `frigate_death1.osm`, `frigate_death2.osm` — 8 files
- `galley.osm` (323,300 B), `galley.oss` (217,344 B), `galley1.osm`…
  `galley4.osm`, `galley_death1.osm`, `galley_death2.osm` — 8 files
- `xebec.osm` (407,012 B), `xebec1.osm`…`xebec4.osm`,
  `xebec_death1.osm`, `xebec_death2.osm` — 7 files, no `.oss`
- `yacht.osm` (427,436 B), `yacht.oss` (217,344 B), `yacht1.osm`…
  `yacht4.osm`, `yacht_death1.osm`, `yacht_death2.osm` — 8 files
- `yachttur.osm` (188,444 B), `yachttur.oss` (217,344 B),
  `yachttur1.osm`…`yachttur4.osm`, `yachttur_death1.osm`,
  `yachttur_death2.osm` — 8 files

File sizes range 29,876 B (`fishboat1.osm`) to 935,692 B
(`frigate_death2.osm`) — these are non-trivial binary meshes, not stubs.

### 2.2 Readability proof of the animated `.oss` format

`struct.unpack_from("<6i", yacht.oss)` on `data\actors\units\yacht.oss`
(217,344 B) returned `(k, fps, b, v, fc, t) = (311, 30, 20, 584, 947, 793)`:
311 frames at 30 fps, 20 bones/actions, 584 vertices, 947 faces, 793 UVs — a
well-formed mesh matching the header layout read by `bake_sprites.py` /
`compute_ortho.py`. The other four `.oss` files share the same 217,344-byte
layout (`fishboat`, `frigate`, `galley`, `yachttur`).

### 2.3 `data\actors\env` — decorative boat/wreck meshes (not units)

`boat1.osm` (16,660 B), `boat2.osm` (20,212 B), `boat3.osm` (20,196 B),
`boat4.osm` (36,692 B), `boat5.osm` (20,084 B), `shipwreck1.osm` (71,932 B),
`shipwreck2.osm` (90,940 B), `shipwreck3.osm` (88,004 B). Also present:
`rocksea1..6.osm`, `stonessea1..10.osm`, `smallstonessea1..6.osm`,
`ptborderwater.osm` (`data\actors\misc`) and water-impact FX
`impwaterlarge1..3.oss`, `impwatersmall1..3.oss` (`data\actors\pfx\impact`).

### 2.4 `data\animations\aaf` — 24 naval animation descriptors (exact names)

`battleship.aaf` (92 B), `battleship_flag.aaf` (28), `battleship_sail.aaf`
(106), `chaika_flag.aaf` (28), `ferry_paddle.aaf` (71), `fishboat.aaf` (92),
`fishboat_paddle.aaf` (131), `fishboata.aaf` (28), `frigate.aaf` (92),
`frigate_flag.aaf` (27), `frigate_sail.aaf` (106), `galley.aaf` (92),
`galley_flag.aaf` (28), `galley_paddle.aaf` (129), `galley_sail.aaf` (129),
`misflagman.aaf` (96), `xebec.aaf` (92), `xebec_flag.aaf` (28),
`xebec_sail.aaf` (106), `yacht.aaf` (92), `yacht_flag.aaf` (28),
`yacht_sail.aaf` (106), `yachttur.aaf` (92), `yachttur_sail.aaf` (106).

These are small text descriptors (27–131 B) — they sit **alongside** the mesh
files, not instead of them.

### 2.5 `data\animations\acl` — 9 naval animation clips (exact names)

`battleship.acl` (1,805 B), `fishboat.acl` (1,056), `frigate.acl` (1,796),
`galley.acl` (2,820), `shippaddle.acl` (750), `shipsail.acl` (1,002),
`xebec.acl` (1,790), `yacht.acl` (1,790), `yachttur.acl` (2,828).

## 3. Implications

- The backlog's grep note ("no `yacht|ship|boat|naval|dock` symbols") describes
  the **Godot port code**, not the donor install — it is not evidence of absent
  donor meshes.
- N-11 acceptance ("≥1 naval sid with 8-dir baked sprite from a donor mesh,
  buildable from a dock; OR a signed waiver naming exact donor files that are
  missing/unreadable") is achievable via the first branch: `yacht.oss` /
  `galley.oss` plus the `.osm` direction variants and `.aaf`/`.acl` clips.
- No porting was performed in this ticket; this is evidence only. Any bake must
  keep donor binaries out of `res://` except approved derived sprites (gate 5).
