---
id: VERIFY-HEIGHT-FIX
ticket: "TERRAIN-VISUAL-WAVE-2026-11-26 / VERIFY-HEIGHT — SECONDARY verification of FIX-HEIGHT's gen/inputs correction"
agent: "worker VERIFY-HEIGHT, reporting to COORD"
date: 2026-11-26
status: DELIVERED__SECONDARY_VERIFICATION__ONE_REPORT__READ_ONLY__NO_CODE_EDIT__NO_GODOT__NO_GIT
owner_file: docs/terrain_swarm_2026-11-26/reports/VERIFY_HEIGHT_fix.md
files_created: [docs/terrain_swarm_2026-11-26/reports/VERIFY_HEIGHT_fix.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "Source-static verification only. No donor GPU A/B frame exists; no capture, gate, runner or Godot job was run by this worker. Nothing here certifies donor fidelity, a visual fix, or a gate pass."
scope_guard: "Exactly one repository file written (this report). The two code files and hil1.json were read only; FIX-HEIGHT was observed editing concurrently and was waited out before the final read. No donor file opened, no Godot job, no git operation, no test/gate/capture."
verdict: "5_OF_5_LITERAL_ITEMS_PASS__4_CAVEATS__NO_PARITY_CLAIM"
snapshot:
  terrain_donor_gen.gd: "mtime 2026-11-26 10:39:31Z, 108,971 B"
  terrain_donor_inputs.gd: "mtime 2026-11-26 10:40:12Z, 38,520 B"
  hil1.json: "mtime 2026-11-26 09:12:37Z (unchanged by the fix)"
---

# VERIFY-HEIGHT — secondary verification of FIX-HEIGHT's correction

## 0. Method and verdict

Read first: `VISUAL_WAVE_CHARTER.md`, `reports/X54_ground_truth_card.md`,
`reports/X23_corrected_relief_grids.md`, `reports/W03_terrace_root_cause.md`, and the
two code files. Initial reads showed the **pre-fix** state
(`inputs.gd:268-269` then set `p.width/p.height` to the native mask size), so I did not
verdict early: I polled file mtimes through two concurrent edit bursts and re-read the
settled files after 30 s of stability. Line numbers below are from the settled snapshot
in the frontmatter only.

| # | Checked item | Verdict | Authority |
|---:|---|---|---|
| 1 | I07 reads `relief_float_grid` (not only `grid`) and applies D05/X26 blend flags | **PASS** | `gen.gd:1779-1802,1807-1824,1833-1843,1858-1864,1886-1899,1903-1907`; `inputs.gd:671-698,703-714` |
| 2 | I17 resamples mask to requested `w/h`; does not override with native 256/320 | **PASS** *(literal); caveat C1* | `inputs.gd:268-269,297-333,359-366,380-389` |
| 3 | Starts stay normalized; B≥58 water thresholds unchanged | **PASS** | `inputs.gd:39-40,372-379`; `gen.gd:122,138,157,865-870,910-916,1101,1454-1457` |
| 4 | `tile_smooth_chains` passed if emitted, honestly skipped otherwise | **PASS** | `inputs.gd:423-438,507-508,564-579,580-624`; `gen.gd:1082,1086,1124-1125,1299+` |
| 5 | No `HEIGHT_SCALE` / noise / dither / face promotion | **PASS** | `gen.gd:463,835,1265,1302`; `inputs.gd:17,39,99`; supporting `mesh.gd:16-17,42` |

Labels: **[O]** observed code/asset literal, **[D]** deterministic consequence, **[I]**
inference, **[U]** UNVERIFIED, PORT APPROXIMATION for port substitutes. Every verdict
is source-level. **No donor parity claim.**

---

## 1. Item 1 — `relief_float_grid` + D05/X26 blend flags: **PASS**

**[O] I17 decode (primary key).** `terrain_donor_inputs.gd:671`
`doc.get("relief_float_grid", null)`; `:672-678` rejects a missing or wrong-sized grid
with no zero padding; `:679-683` packs f32; `:689-690` emits
`"relief_float_grid": grid` and `"grid_source_key": "relief_float_grid"`. The optional
canonical `grid` is a **separate** override, never an alias:
`inputs.gd:703-714` (`doc.get("grid")`, size-gated, emitted only as `out["grid"]`).

**[O] I07 consumer (not only `grid`).** `terrain_donor_gen.gd:1807-1811`:
`grid_v = pat.get("grid", null)`; `if grid_v == null: grid_v = pat.get("relief_float_grid", null)`.
`:1812-1820` packs a direct-I02 `Array` caller into `PackedFloat32Array`; `:1821-1824`
rejects bad dimensions/size. No scan, shift or synthetic grid. Relief placement counts
a height stamp only when a grid key is present: `gen.gd:2170-2171`.

**[O] Blend flags decoded and applied.** `inputs.gd:684-698` reads all eight fields from
`flags` (Scale, Min, Offset, TerrainScale, Replace, ReplaceForWater, Stand, Smooth).
I07 additionally normalizes nested `flags` for direct I02 JSON callers on a shallow
copy, explicit top-level keys winning: `gen.gd:1779-1802` (each `if not pat.has(...)`).
Application: `gen.gd:1833` scale, `:1839` Min pivot, `:1840` Offset, `:1841`
TerrainScale, `:1842` Replace, `:1843` ReplaceForWater; `:1858-1864` the two f32-rounded
scale paths (non-water `(g-Min)*Scale+Min`, water `g*Scale`); `:1886-1894` the three
X26 write paths (ReplaceForWater `g+Offset`, Replace `base_h+g+Offset`, Smooth
`(base_h-h0)*TerrainScale+g+Offset+h1`); `:1899` f32 setter. The smooth post-pass is
gated only by the Smooth flag, including the ReplaceForWater branch:
`gen.gd:1903-1907`. This is the D05 F4 / X26 formulation cited at
`gen.gd:40-48` and `X54` row 3; `Max` is never read as a clamp.

---

## 2. Item 2 — requested-size mask, no native override: **PASS** (literal), caveat C1

**[O] Resampler.** `terrain_donor_inputs.gd:307-333` `_resample_mask_image(img, mw, mh, w, h, skipped)`:
invalid requested grid → `SKIPPED` with no mask emitted (`:309-311`); native size →
`NATIVE`, no resample (`:312-314`); otherwise a deterministic resize of a **duplicate**
image to exactly `w×h` (`:315-320`), with a labelled nearest fallback
(`:322-333`, `floor(y*mh/h)`, `floor(x*mw/w)`, appended to `skipped`).

**[O] Requested grid wins.** `inputs.gd:359-363` calls the resampler and rejects a
byte array that is not `w*h`; `:364-366` sets `p["mask_b"]=mb`, `p["width"]=w`,
`p["height"]=h` — comment at `:365` reads "REQUESTED grid; never native mask size".
The former `p["width"]=mw / p["height"]=mh` native override (pre-fix lines 268-269) is
**gone**. Telemetry records both grids and the method: `inputs.gd:380-389`
(`source_width/source_height` vs `width/height`, `resample`, `resample_label`).
The caller supplies the real requested game grid: `terrain_donor_world.gd:231`
`build(game, size.x, size.y)`.

**[D]** For the 240×240 capture in W03 §3.1 the mask bytes now have `240²` cells and
`p.width/p.height = 240/240`, so I07 sizes I06 to 240² instead of the mask's native
320². No runtime capture was run by this worker; this is a source consequence only.

---

## 3. Item 3 — normalized starts and unchanged water thresholds: **PASS**

**[O] Starts.** `inputs.gd:372-373` reads the manifest's normalized `nx, ny` unchanged;
`:374-377` converts to donor-centred cells with the **requested** `w/h` (comment:
"Starts stay normalised source coordinates; only the donor-centred conversion uses the
requested grid, never the native mask grid"); `:378-379` emits `p["starts"]`. I07 still
records white starts from the mask itself and zeroes/skips them at
`gen.gd:865-870`; consumes `p.starts` at `:1437` and `:2242`; converts centred → cell
at `:1454-1457`. No start value was renormalized, re-seeded or invented.

**[O] Thresholds — all unchanged.** `inputs.gd:39` `MASK_HEIGHT_SCALE = -1.1` (the
donor formula, not a multiplier fudge) and `:40` `MASK_B_WATER_BYTE = 58`;
`gen.gd:122` `C_WATER_HEIGHT = -1.1`, `:138` `C_WATER_BYTE = 58` (comment: "B>=58 is
the h<-0.25 boundary"), `:157` `C_TILE_WATER_HEIGHT = -0.25`. The bed formula remains
`hwater = -1.1*(fb*(1+fr*3.5))` at `gen.gd:910` and is written at `:916`; tile water
classification remains `b > 0 and h < -0.25` at `:1101`. These match `X54` rows 2/6
and its §2 "B>58 is off-by-one" entry: no threshold was raised, lowered or replaced.

---

## 4. Item 4 — `tile_smooth_chains` passed or honestly skipped: **PASS**

**[O] I17.** Direct canonical table from `constants.json`: `inputs.gd:507-508`;
structural validator `_valid_tile_smooth_chains` (name/id/prob shape check):
`:423-438`; validation and counting of the direct table: `:564-579` (malformed →
append a skip note and `p.erase` at `:567-569`); rebuild from `TileName`/`Prob` rows
with 22-slot preservation and no fabricated group/entry: `:580-621`; incomplete or
absent table → explicit skipped note, no invented table: `:588`, `:624`.

**[O] I07.** `gen.gd:1082` reads `p.get("tile_smooth_chains", [])`; `:1086` emits an
honest skip note when absent; `:1124-1125` passes the chains into `_smooth_tiles`
only when both chains and `tile_id_to_name` are present. `_smooth_tiles` (`gen.gd:1299+`)
keeps the 3 H-then-V in-place passes and no face promotion (`:1302`). No gate was
lowered and no smoothing table was fabricated.

---

## 5. Item 5 — forbidden constructs: **PASS**

**[O] gen/inputs.** The only `HEIGHT_SCALE` occurrence in `terrain_donor_gen.gd` is the
telemetry string `"...no HEIGHT_SCALE multiplier"` at `:463`; there is no scale const
or applied multiplier. "noise" appears only in the prohibition comment at `:835`
("Do NOT port its Gaussian/noise"), and "face promotion" only in prohibition comments
at `:1265` and `:1302`. In `terrain_donor_inputs.gd`, "noise/dither" appears only in
the scope comment at `:17`, `MASK_HEIGHT_SCALE` at `:39` is the donor `-1.1` mask
formula, and `:99` states FNV-1a is a selector, not terrain noise. No dither/noise
field, face promotion, invented donor constant or threshold change exists in either
file. Downstream contract supports this: `terrain_donor_mesh.gd:16-17,42` declares
no synthetic noise/dither/face promotion and `HEIGHT_SCALE = 1.0` as a labelled
PORT contract (verification only; mesh.gd was not edited by this worker).

---

## 6. `hil1.json`: 3.8613 / Scale 0.65 against the code path **[O]+[D]**

**Asset literals** (`variant3d/assets/terrain_new/patterns/hil1.json`):
`:46-56` `flags` = `Scale 0.649999976158142` (f32 literal 0.65), `Min 0.0`,
`Max 3.86130237579346`, `Offset 0.0`, `Replace false`, `ReplaceForWater true`,
`Smooth false`, `Stand true`, `TerrainScale 1.0`; `:58-60` `grid_offset 968`,
`w 25`, `h 41`; `:18324` start of `relief_float_grid`; `:18884` its maximum cell
`3.861302375793457` (bit-equal to `flags.Max`). `X23 §4.3:177-186` independently
confirms the bit-exact `pattern.lib` Max `3.861302375793457` and G=968.

**Code path.** `inputs.gd:671-683` → `:689-698` → `gen.gd:1809-1824` (grid) and
`:1779-1802` (flags normalization) → `:1843` (`rep_water = true`) → `:1864`
(`g = _pf(g * scale)`, i.e. Min pivot is not used on this branch) → `:1887`
(`stamped = g + hoff`, `hoff = Offset = 0`) → `:1899` (`set_height`, f32).
Smooth post-pass is **skipped** for hil1 because `Smooth=false` (`gen.gd:1906`).

**[D] Expected maximum hill contribution.** With the default `f32_each_op` model
(`gen.gd:260` `stamp_precision_model = "f32_each_op"`, `_pf` at `:1888-1894`):

```
g_max = 3.861302375793457
Scale = 0.649999976158142     (flags.Scale, f32 0.65)
g_max * Scale                = 2.509846452205124  (f64 intermediate)
_pf(g_max * Scale)           = 2.5098464488983154 ≈ 2.50985
stamped = g + Offset(0)      = 2.5098464488983154
```

Using the literal 0.65 instead of the stored f32 gives
`3.861302375793457 * 0.65 = 2.509846544265747`, which rounds to the **same**
f32 value. Therefore the expected peak is **≈ +2.50985 stored-height units above a
zero base**. Because `ReplaceForWater=true`, that value is written **absolutely** to
the cell (`g + Offset`); it is *not* added to `base_h`, so no double-counting with the
`-1.1*B/255` bed. The peak is below the donor plateau constant `C_PLATEAU_HEIGHT =
2.964` (`gen.gd:119`) — the 0.65 is the donor's own `HeightFieldScale`, not a
tuning knob and not a `HEIGHT_SCALE` fudge. This is a static numeric expectation,
not a measured render.

---

## 7. Remaining blockers / caveats

- **C1 — resample kernel is PORT APPROXIMATION, not donor nearest.** The primary path
  is `Image.INTERPOLATE_BILINEAR` (`inputs.gd:317-321`, explicitly labelled
  "donor nearest sampler not claimed"); the donor-style `floor(x/W*srcW)` nearest tap
  is only a fallback (`:322-333`). W03 §4(b)/§5.4 handoff asked for donor nearest
  sampling at the I17 boundary. Item 2's literal requirement (requested size, no
  native override) is met, but **the kernel's donor fidelity is UNVERIFIED**.
- **C2 — no visual/gate evidence.** No capture, gate, runner or Godot job was run by
  this worker; nothing here shows the `240c` terraces/bands are gone. W03's separate
  I10 eye-plane `uv_repeat` + `fract` defect (shader, not gen/inputs) is outside this
  fix and remains open.
- **C3 — occupancy semantic gap retained, not invented.** `inputs.gd:715-725` emits
  the `(h-1)×(w-1)` lattice as the stand footprint; `gen.gd:1849-1855` gates `w*h`
  height vertices only when an occupancy array is at least `w*h`, leaving the native
  vertex-byte expansion **[U]** (W03 §4(c) owner question). No expansion was
  fabricated by this fix.
- **C4 — placement is still hook-dependent.** Actual rendered silhouette depends on
  position draws and the `[U]` row-sign / rotation-rounding / global-clamp hooks
  (`gen.gd:1873-1881,1895-1898`); the ≈2.51 figure above is the per-cell peak a
  successful stamp can write, not a predicted visible hill height.

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor
> GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

*End of VERIFY-HEIGHT. Exactly one repository file written; code and assets read only;
no donor binary executed, no Godot job, no git operation, no parity claim.*
