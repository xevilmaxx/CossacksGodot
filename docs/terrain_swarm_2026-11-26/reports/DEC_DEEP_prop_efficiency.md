# DEC_DEEP — terrain prop efficiency (donor READ-ONLY)

Target pinned: `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`,
sha256 `87f0f3c130b0…`). Deep mode, donor READ-ONLY. No code / Godot / git
touched. This turn wrote exactly one file (this report).

Pass budget: max 5 passes per function. Actual: `sub_755f30` ×3
(show / callees / api); `sub_755920`, `sub_755664`, `sub_755bc8`,
`sub_7cca74`, `sub_755db4` ×1 decompile each; strings/bytes searches ×1
each. No function exceeded budget.

Prior context reused without re-claiming: DEC-VIS-02 `fnd_44/45/46/50`
(GameObjectsStand loop shape, placement math, LOD 0..150 vs 0..2500). All
statements below are freshly evidenced this turn except where explicitly
marked "prior dossier".

No parity claim is made about any port file.

---

## 1. [O] Loop anchor — `sub_755f30` @ `0x755f30`

- `native_function_show` (`ev_621777064c3bb174a6d62c3cf10bed87455f3f6edfb76e0fcb2572957d3f5a`):
  entry `0x755f30`, end `0x75c187`, size 25175 bytes, 234 basic blocks,
  6751 instructions, 5 callers, 662 outgoing calls, `discovered_by: call`.
- `native_function_callees_list`
  (`ev_1988761f0904d8a646115e225193615c0bdedf6b30fc701e41aa0619592a9b0b`):
  662 internal calls enumerated. Repeated per-type stamp dispatchers
  `sub_755920`, `sub_755bc8`, `sub_755664` recur dozens of times
  (e.g. sites `0x757564`, `0x757578`, `0x757932`, `0x75809a`, `0x7580ae`,
  `0x75912e`, `0x759142`, …); tail section calls `sub_7cca74` at site
  `0x75bd68`, plus `sub_810498`, `sub_80f848`, `sub_890d00/890cd0/890d28`.
  The only `sub_403aXX` callee is `sub_403a28` at single site `0x7563fd`.
  **No `sub_403a0c` (Delphi Random) edge appears in the 662-call list.**
- `native_api_show` (`ev_19b3b321399b122fb58aa81f4b02fa162d517de84273161cafae93bee699b9ee`):
  `0 calls into system or library APIs, 662 internal calls, 0 unresolved
  indirect calls`. Generation-time placement therefore issues no OS,
  file, RNG-import, or draw call of its own; all work is internal
  integer/float transform + stamp dispatch.
- Name searches are negative, which itself is evidence about where the
  schema lives (`ev_32f55f7841ad47e8b0f73235ff700350c85c7e7d104537a21a21e515b45505`,
  `ev_ecc47b7b03e38567d87c8c19ef79e9687a21b4d3bc9a7538687a41a21b45505`):
  `core_feature_find "GameObjectsStand"` → 0 strings, 0 function names,
  0 imports; `"ObjectsScale"` → likewise 0/0/0. Placement-field names are
  **not** compiled into `cossacks.exe`; they live in script/actor data.

## 2. [O] Per-record helpers — what each call site costs

Decompiled in one pass
(`ev_f03af24d05e135ac3fba592a82bf10590649f8a1c9919c542cd4d1dbfe79dea0`):

- `sub_755920` @ `0x755920`: half-extent branch ladder. Reads two
  half-extents (`>>1`), then a 3×3 quadrant cascade on
  `(−esi ? arg_fffffff8)` / `(−ebx ? arg_fffffff4)` selecting one of nine
  stamp targets (`+0xa8…+0xe8` slots, `sub_59b854(edi)`), with a trailing
  4-byte rotate block (`label_755b68`). Pure compares, adds, one indirect
  stamp call. No loop, no RNG.
- `sub_755664` @ `0x755664`: same ladder shape but with rotation-guard
  prologue (byte-rotate at `label_7556d5`) and an `+0x83` flag gate that
  optionally remaps four bytes through `sub_755578` before the identical
  nine-way dispatch (`sub_59b8a4` / `sub_82ecac`). Same fixed-cost class.
- `sub_755bc8` @ `0x755bc8`: 24-byte record copy (`rep movsd`, ecx=6),
  one `fcomp` against constant at `0x755c58`, one conditional `fadd` of
  `tbyte [0x755c5c]`, `fdiv` by `[0x755c68]`, then a counted copy loop
  (`eax = sub_4a6a5c(); … while(eax--)` rotating 4 bytes per record).
  Cost is O(records accepted at this station), still no RNG.

Second decompile pass
(`ev_c3dd586596b09f1170e03aece993bec715167bf7cffa0eeb762adc51aedeedae`):

- `sub_7cca74` @ `0x7cca74`, size 15 (`ev_9b305d80e15a2955f0afdeffe0a0d9a5d1dffa23ad90a88bcd9612c45eae7a06`
  confirms 1 function match): whole body is
  `sub_4cb27c(arg_8); return rax;` — a tail-call wrapper, i.e. the final
  per-object orientation/commit step costs one call.
- `sub_755db4` @ `0x755db4`: nested `esi`/`ebx` lattice walk
  (`arg_ffffffe4`/`arg_ffffffe0` counters, `goto label_755e1f/755e31`)
  doing `dx²+dz²` vs `radius²` (`fmul`, `faddp`, `fcompp`/`fnstsw`/`sahf`),
  then four `sub_7553a0` height taps averaged by `fdiv [0x755ee4]`
  (= 4.0 constant pool) before `sub_7551a8`. This is the height-sampling
  kernel reused around prop stamping, not a per-prop RNG draw.

Abridged pseudocode (register lifter, calling convention assumed):

```c
// sub_755920 — quadrant dispatch (excerpt)
esi = *(u32*)(edx+8) >> 1; ebx = *(u32*)(edx+4) >> 1;
if (-esi <= z && esi <= z && -ebx <= x && ebx <= x)
  sub_59b854(/* slot +0xc4 */);   // 1 of 9 slots +0xa8..+0xe8
else if (...) sub_59b854(/* neighbour slot */);
// trailing 4-byte rotate at 0x755b68
// sub_755bc8 — record copy (excerpt)
rep movsd edi,esi,6;                       // 24 bytes
if (fcomp([0x755c58]) < 0) [ebp+8] += tbyte [0x755c5c];
n = sub_4a6a5c(); while (n--) rotate4(ebx,esi);
// sub_7cca74 — whole body
sub_4cb27c(arg_8);
```

## 3. [O] Angle filter / visibility gate (prior dossier shape, re-anchored)

Prior dossier `fnd_46` (DEC-VIS-02) established the record loop visits
every record with **no RNG** and the fast path
`minangle<=0 && maxangle>=90` bypasses per-object bounds/angle filtering;
otherwise two donor normal-angle metrics must both lie strictly between
`minangle` and `maxangle`. This turn did **not** re-derive new angle
addresses (would have exceeded the 5-pass budget on `sub_755f30`); the
shape is cited, not re-proven, and the supporting new fact is the callee
list above having no Random edge plus zero API calls.

## 4. [O] Batching / instancing — generation vs runtime split

- Generation time (`sub_755f30` family): **no instanced-draw batching**.
  Objects are stamped one record at a time into tile/height structures
  via the `sub_755920/755664/755bc8` dispatchers. Throughput comes from
  (a) visiting every record once, (b) fixed-cost integer compares and a
  single indirect stamp call per record, (c) no per-record RNG, (d) no
  syscalls. There is nothing to "instance" here — the output is map data.
- Runtime: the engine reuses actors through the LOD actor framework.
  `native_strings_find "lod"`
  (`ev_1fe664bd2b2b8696562acbdfdba2e1c5a8e1437fa5bd712499ef99480d80cf62`):
  4 `.rsrc` matches — `LXShaderLOD` @ `0x958662`, `_XLODActorLibrary`
  @ `0x958d2d`, `4XLODActor` @ `0x958d40`, `XLODProxyActor` @ `0x958daa`.
  That is the entire exe-visible footprint of the batching/instancing
  layer; mesh sharing and distance culling live in actor/script data and
  the renderer, not in the placement loop.

## 5. [D] LOD `0..150` vs `0..2500` — where the numbers live

- Prior dossier `fnd_46`: actor LOD has one mesh range `0..150` and a
  separate shader/distance range `0..2500`.
- This turn: neither bound appears as an exe float immediate.
  `native_bytes_find` `00 00 16 43` (150.0f LE)
  (`ev_6c832e3b1cdc574517547820bdb970ae0c2210e0a6bfa05f793f0db645f9f65a`)
  → 0 matches; second pattern probe for the 2500.0f neighbourhood likewise
  0 matches (`ev_b8378682ce2618d1c9e4e2e0b022de125cefc9334f26790002374b4cdc56a617`).
  Combined with the zero string matches for the placement-field names,
  the derived reading is: **LOD bounds are actor-data constants
  (`.osm`/actor defs + script), consumed by the `XLODActor` runtime, not
  immediates in `cossacks.exe` CODE.** Do not hunt them as `flt_XXXX`
  in the exe; read the actor def instead (out of scope for this
  exe-pinned pass).

## 6. [D] Per-record cost model (for `terrain_donor_props.gd` batching)

Per accepted record, donor pays approximately:

1. 2 half-extent loads + shifts, ≤4 signed compares (quadrant ladder);
2. 0–4 byte rotates (only when straddling a stamp edge);
3. one 24-byte `rep movsd` + one conditional float adjust (in the
   `755bc8` path);
4. one indirect stamp call (`59b854/59b8a4/82ec5c/82ecac`) or one
   `7cca74→4cb27c` commit;
5. height path only under `ObjAutoOffset`: 4 taps + average ÷ 4.0.

No hash, no RNG, no allocation, no syscall per record. Throughput is
therefore linear in record count with a tiny constant — the port wins by
copying the structure (single pass, precomputed rotation/scale, early
angle-bypass), not by micro-optimising the transform.

## 7. Concrete port recommendations for `terrain_donor_props.gd`

1. **Single linear pass, no per-prop RNG.** Precompute per stamp:
   `rot = PI − rotangle`, `ObjectsScale`, half-extents, height
   offset/flags once; then per record only rotate XZ, scale, add centre.
   Never call `RandomExt`/Delphi-Random inside the loop — donor proves
   zero such calls (662 callees, zero API, §1).
2. **Keep the angle fast-path first.** If `minangle <= 0 and maxangle >= 90`,
   skip both normal-angle metric tests entirely; else require both metrics
   strictly inside `(minangle, maxangle)`. Branch order matters more than
   the trig itself.
3. **Batch by stamp station, not by mesh.** Mirror the donor's nine-way
   dispatch: bucket accepted records per `(station, slot)` during the pass,
   then issue one `MultiMeshInstance` (or one decal/height commit) per
   bucket. Do not create one node per prop.
4. **Split the two LOD ranges.** Mesh visibility `0..150` drives which
   `MultiMesh` LOD is visible; shader/distance fade `0..2500` drives only
   material/shader LOD, never culls the instance. Wiring both to the same
   visibility range will pop props at 150 m that the donor still shades to
   2500 m.
5. **Height-snap conditionally.** Sample terrain height only when the
   record's `ObjAutoOffset` (or equivalent) flag is set; otherwise use
   `Y + ObjectsHeightOffset` directly. The donor's 4-tap average (÷ 4.0 at
   `0x755ee4`) runs only on that path.
6. **Do not bake LOD numbers as exe floats.** Read `150` / `2500` from the
   actor-data side (or a single config), matching the finding that they are
   absent from exe bytes/strings. Hard-coding them as shader immediates
   diverges from where the donor keeps them.

## 8. [U] Unknowns / explicitly not proven

- Exact virtual addresses of the two angle-metric loads and the
  `minangle/maxangle` threshold words inside `sub_755f30` (not re-walked;
  would cost passes beyond budget).
- Which of the nine `+0xa8…+0xe8` slots corresponds to which named
  `Objects*` station (needs script↔struct join, out of scope).
- Runtime instancing granularity of `XLODActor` (shared-mesh vs per-actor
  proxy path) — only framework names observed (`0x958662…0x958daa`).
- Authoritative source file of `150` / `2500` (actor `.osm` vs script) —
  only proven absent from exe CODE/strings, not located positively.
- Whether any prop station sets `AutoCentering` (terrainmesh finding says
  false there; props not re-checked).

## 9. Method note

- Pinned target re-verified via session (active `t_87f0f3c130b0`).
- 5-pass budget respected; pass counts in header.
- Evidence ids are first-hand this-turn outputs; prior-dossier items are
  labelled as such. File-byte and string absences carry the tools'
  stated limits (packed/built-at-runtime blindness, data-sections-only).
- No donor file was written; no port file was touched.
