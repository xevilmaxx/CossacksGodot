---
id: A02
task: "How much of the terrain pattern/artifact load comes from alpha_patch_uv() + the mask-to-RGB multiply?"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "Analysis only. Read the charter, the full shader, DALPHA-01/02, the tile-index manifest and atlas pixels. Wrote exactly one report. No shader, data, test, config or git edit; no runner submission."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: "docs/terrain_swarm_2026-11-25/reports/A02_alpha_pattern.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
donor_parity_claim: false
evidence_ids: [A02-E1..A02-E11]
---

# A02 — alpha patch / mask-to-RGB artifact attribution

## 0. Mandate and stance

CHARTER §2 suspect 2 asks how much of the owner-visible *patterns* come from
`variant3d/shaders/terrain_tileindex.gdshader:365-378` (`alpha_patch_uv()`) and `:427`
(`rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular`). This report answers
that from code, port pixels and the donor-grounded structure in
`docs/coord_swarm_2026-11-25/reports/DALPHA_01_alpha_subrect.md` / `DALPHA_02_patch_mapping.md`.

**Stance:** the 64² patch *geometry* is donor-grounded (DALPHA-01 §5 verdict 1, RESOLVED);
the tile-id → patch *choice* is explicitly **PORT APPROXIMATION / CONFIRMED_UNVERIFIED**
(DALPHA-01 §5 verdict 5; DALPHA-02 §5). Everything quantified below is a property of the
**port** implementation. **No donor parity, no donor visual A/B, no donor GPU frame is claimed.**

Label key: **[O]** observed (read from code / pixels / images), **[D]** derived (arithmetic on
observed values), **[I]** inference, **[U]** UNVERIFIED.

### Evidence register

| ID | Evidence | Label |
|---|---|---|
| **A02-E1** | Shader `:365-378`: `id=floor(abs(tile))`, `dir=id%4`, `variant=(id/4)%4`, `half=(id/16)%2`, `opposite=(id/64)%2`, `row/variant` mirrored by `opposite`, `cell=(half*4+variant,row)`, half-texel `clamp(local,0.0078125,0.9921875)`, `return (cell+t)/vec2(8,4)` | [O] |
| **A02-E2** | Shader `:427`: `rgb = rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular`; `ALPHA=1.0` at `:475` | [O] |
| **A02-E3** | Shader `:316` `v_alpha_uv = fract(v_st * uv_repeat) * alpha_uv_scale`; `:214` `uv_repeat=(0.5,0.5)` (2 m/cell); `:392` `tile_rgb(v_tile, fract(v_st*uv_repeat))` | [O] |
| **A02-E4** | `variant3d/assets/terrain/atlas/alpha.png` is 512×256 grayscale; re-packed R→A at `world3d_terrain.gd:662-675`. Measured 8×4 patch means (Pillow, this agent) reproduce DALPHA-01 §3.2 exactly: row0 `255,52.3,50.5,132.4,255,77.7,72.7,154.1`; row1 `56.5,136.3,157.9,213.5,58.3,157.7,180.1,206.4`; row2 `45.6,153.5,134.2,210.0,82.8,174.5,143.1,199.9`; row3 `136.9,210.1,216.4,0.0,152.2,196.7,203.3,0.0` | [O] |
| **A02-E5** | Applying A02-E1 to the 124 named ids in `tile_index_atlas.manifest.json` gives the id→patch table in §2 (computed this agent) | [D] |
| **A02-E6** | DALPHA-01 §3.4 (derived from donor `alpha.bmp` edge statistics): row 0 darkest on top=N, row 1 left=W, row 2 right=E, row 3 bottom=S; rows encode a dark *edge* + organic interior lobes | [D, cited] |
| **A02-E7** | No neighbour input exists: `world3d_terrain.gd:1407` writes one tile id into `UV2.x`; DALPHA-02 §5 Q2 confirms direction/half/opposite are id stand-ins | [O] |
| **A02-E8** | Charter images opened: `p0_final_formula.png` and `smallmap64_terrain_only.png` = flat olive field, fine grain, faint diagonal streaks/repeating bands, soft blocky patches; donors `cossacks-3-v1-498085.jpg` / `articolo-787.jpg` = organic multi-scale mottling, grey cliff faces, no grid/streaks | [O] |
| **A02-E9** | `world3d_terrain.gd:1310-1312` places one vertex at each **cell centre**; `:1408-1418` triangulates across cell centres; shader `:324` `v_tile = UV2.x` is a **varying** | [O] |
| **A02-E10** | Shader `:235-246` `mask_to_alpha` diagnostic (default 1.0), `:491-496` published A/B contract: `0.0 ⇒ mix(1.0,a,0.0)==1.0`, ALPHA still 1.0 | [O] |
| **A02-E11** | `world3d_terrain.gd:718-719` deliberately leaves `mask_to_alpha` at shipped 1.0; no A/B frame exists | [O] |

---

## 1. Direct answers to the four ticket questions

### Q1 — Does the tile-id-derived `dir/variant/half/opposite` mapping create repeated blotches?

**Yes — [D], high confidence; this is the port's dominant mask-driven artifact mechanism.**
`cell` depends only on the low bits of the tile id: `dir = id mod 4` (period 4),
`variant = (id div 4) mod 4` (period 16), `half = (id div 16) mod 2` (period 32), and
`opposite = (id div 64) mod 2` mirrors row and variant. Therefore
**`cell = f(id mod 32)` for ids 0..63 and the mirrored `f` for 64..127** (A02-E1/E5).
The atlas has 124 named ids but only 32 patch roles: the same organic lobe/dark-edge shape is
re-used every 32 ids, across unrelated families (e.g. `grass2`(1), `sand8`(33) and `alpha0b`(110)
all land on patch `(0,1)`, mean 56.5; `grass3`(2), `sand9`(34), `test6`(77), `test25`(109) all land
on `(0,2)`, mean 45.6). Because the donor smoothing in `game.gd:_assign_tileblocks()` concentrates
cells on a handful of ids (CHARTER §2 item 5), a given blotch shape is stamped verbatim on every
cell carrying that id. There is no neighbour direction to break the repetition (A02-E7).
**Label: derived from port code/pixels; the donor would have used a neighbour-aware engine-written
UV (DALPHA-01 §2.4) — that rule stays [U].**

### Q2 — Is the mask applied on every cell, or only at transitions as in the donor?

**Port: on every flat-tile fragment [O]. Donor: a transition/blend weight [D/I, cited].**
The flat branch samples one 64² patch unconditionally at `:419` and `:427` multiplies **every**
fragment by `a`; there is no boundary test anywhere in `fragment()`. `v_alpha_uv` is the 2 m
cell-local `fract` coordinate (A02-E3), so every 2 m cell receives a full patch: a dark edge on
one side (row→N/W/E/S, A02-E6) plus organic interior lobes, repeated with the 2 m `fract` phase.
In the donor the mask arrives as per-vertex `gl_MultiTexCoord1` written by the engine mesh builder
(DALPHA-01 §2.4) and is composited by `bmTransparency` over a **second base-tile pass**
(DALPHA-01 §6.4: `(0,0)/(4,0)` = "no transition" sentinel, `(3,3)/(7,3)` = "full cut"). It is a
*crossfade weight at block boundaries*, not a per-cell darkening factor; the port has one pass, so
folding it into a single tile's RGB darkens instead of blending. **The exact donor application
semantics remain [U]** (DALPHA-01 §5 verdict 5, §8 Q6).

### Q3 — What happens if `mask_to_alpha = 0`?

`mix(1.0,a,0.0) == 1.0`, so `:427` reduces to `rgb = rgb * v_packed + v_specular`; `ALPHA` stays
1.0 (A02-E2/E10). Consequences **[D]**:

- *All* mask-driven darkening disappears: the 8 black-tile ids (§2) become normal terrain, the
  full-cell dark lobes/bands vanish, and the id-mod-32 blotch shapes vanish.
- The terrain does **not** become bright or transparent — it keeps the donor atlas RGB and the
  donor sun/ambient/diffuse product. No sky bleed (that was the pre-MASK-ALPHA-FIX bug).
- What remains is the *other* suspects: 2 m verbatim RGB repetition (CHARTER §2 item 1),
  nearest filtering (item 3) and the flat olive palette (item 4). So an A/B at `0` cleanly
  partitions "mask contribution" from "atlas/palette contribution".
- This is a **diagnostic, not a fix**: it also removes legitimate transition shading. The binding
  is deliberately left at 1.0 today (A02-E11); no A/B frame has been produced.

### Q4 — Can we confine the mask to tile borders using `local_uv` proximity to 0/1?

**Technically yes, cheaply — [D] — but it mitigates rather than reproduces the donor.**
`v_alpha_uv` is already the cell-local coordinate in `[0,1)` (A02-E3), so
`vec2 e = min(local, 1.0-local); float edge_d = min(e.x,e.y);` gives distance to the 2 m cell
border; `a = mix(1.0, a, 1.0 - smoothstep(w0,w1,edge_d))` restricts modulation to a soft band
(P2 in §4). Two warnings:

1. The existing `clamp(local,0.0078125,0.9921875)` at `:376` is a **half-texel inset into the
   64² patch**, not cell-border confinement — do not mistake one for the other [O].
2. With one tile id per cell, a border-only mask draws a **2 m grid of dark lines** — a different,
   possibly worse, artificial pattern. The donor's masks are organic 64² crossfades between two
   block ids; a thin border band discards most of the organic shape and cannot crossfade without a
   neighbour sample. **Label: PORT APPROX mitigation; needs a visual A/B, no parity claim.**

---

## 2. The id → patch table, and why black/blotchy cells are inevitable

Applying A02-E1 to each of the 124 atlas ids and reading the patch mean from A02-E4 **[D]**:

| Patch mean / mask factor `a` | Count of ids | Example ids → names |
|---:|---:|---|
| **0.0 / 0.000** | **8** | 15 `grass_ground2`, 31 `sand6`, 47 `sand7f`, 63 `rock6vf`, 64 `rock6vs`, 80 `test9`, 96 `sandsea4`, 112 `desert2` |
| 45.6–58.3 / 0.18–0.23 | 19 | 1 `grass2`, 2 `grass3`, 4 `grass5`, 8 `grass9`, 17 `rock1`, 18 `rock2`, 20 `rock4`, 24 `rock8`, 33 `sand8`, 34 `sand9`, … |
| 72.7–83.3 / 0.29–0.33 | 11 | 24/56/87/119 family, 52 `sand9s`, 93 `sandsea1`, … |
| 132.4–158.0 / 0.52–0.62 | 39 | 3 `grass4`, 5 `grass6`, 10 `ground1`, 26 `sand1`, 73 `test2`, … |
| 174.5–216.4 / 0.68–0.85 | 40 | 7 `grass8`, 13 `grass_rock1`, 27 `sand2`, 97 `sandsea5`, 98 `sandsea6`, … |
| **255 / 1.000** | **7** | 0 `grass1`, 16 `grass_ground3`, 32 `sand7`, 48 `sand7s`, 79 `test8`, 95 `sandsea3`, 111 `desert1` |

(The table is the full 124-id census, computed with the manifest. Counts:
8 + 19 + 11 + 39 + 40 + 7 = 124.)

Two structural consequences **[D]**:

- **8 ids map to the constant-0 sentinel patches `(3,3)/(7,3)`** → `a=0` → `:427` yields
  `rgb = 0 + v_specular`. For flat ground `specular_rgb = 0` (shader `:160-163`), so these cells
  render **pure black**. These ids are not exotic: `grass_ground2` is a ground family, and
  `rock6vf`/`rock6vs` are exactly the cliff-face tiles promoted by `world3d_terrain.gd:1340-1350`
  — black cliff faces are a direct, testable prediction. DALPHA-02 §5 Q4 explicitly flagged that
  sentinels "can now be selected" but did not quantify the count.
- **Only 7 ids (notably the dominant `grass1` id 0) get `a=1`**. Everything else is darkened by
  15%–82% *before* `v_packed`, so the whole field is pushed toward the dark olive seen in
  A02-E8. The darkest ids are precisely the detail/transition tiles that three `SmoothTileMap`
  passes (`game.gd:2028`) spread along tile boundaries — hence *soft blocky patches at
  transitions*, matching the charter description.

### Interpolated tile id — an amplifier [O/D]

`world3d_terrain.gd:1310-1312` builds **one vertex per 2 m cell centre** and `:1408-1418` connects
them into triangles; shader `:324` passes `UV2.x` as an interpolated varying. `alpha_patch_uv()`
applies `floor(abs(tile))` at `:366` to that interpolated float, so the patch index can **step
mid-triangle**, and `tile_rgb()` (`:332-338`) has the same issue. This means the blotch boundaries
need not align with cell boundaries at all — it explains irregular rather than axis-aligned
patches (A02-E8). **This is outside A02's patch scope; flagged for COORD as a separate cause.**

---

## 3. Ranked causes (mask-related share only)

| Rank | Cause | Label | Evidence | Symptom it explains | Confidence |
|---:|---|---|---|---|---|
| **1** | Constant-0 sentinel patches selected by 8/124 tile ids → `a=0` → black cells/cliff faces | [O]+[D] | A02-E1, E4, E5, E2 | Hard black blotches; black rock faces | **High** |
| **2** | Full-cell mask modulation with 2 m `fract` repeat: dark edge + organic lobe applied to every cell | [O]+[D] | A02-E1, E2, E3, E4, E6, E8 | Repeating bands / faint diagonal streaks, soft blotches | **High** |
| **3** | `cell = f(id mod 32)` aliasing reuses the same 32 patch shapes across unrelated tile families | [D] | A02-E1, E5, E7 | *Repeated identical* blotch shapes | **High** |
| **4** | Interpolated per-vertex tile id → patch index steps inside a quad | [O]+[D] | A02-E9, E1 | Irregular blotch edges; extra speckle | **Medium (amplifier)** |
| **5** | Global mask darkening (most ids `a≈0.2–0.6`) flattens contrast into uniform olive | [D]+[O] | A02-E2, E4, E8, E11 | Flat dark olive field; low large-scale variation | **Medium** |

**Attribution statement [I]:** ranks 1–3 are fully explained by the two lines in scope
(`:365-378` + `:427`) and are the *mask-driven* share. Rank 4 is a related mesh/shader-contract
issue, rank 5 overlaps the charter's separate palette suspect. Whether mask effects dominate the
2 m RGB repetition / nearest-filter artifacts (CHARTER §2 items 1 and 3) **cannot be decided
without the `mask_to_alpha=0` A/B (P3)** — no such frame exists (A02-E11). No donor-parity
statement is made.

---

## 4. Concrete patch snippets (proposals only — NOT applied)

All snippets are GDS shader code for `terrain_tileindex.gdshader` and carry explicit labels.
They are **proposals for an implementation agent**; A02 edited nothing.

### P1 — Guard the constant-0 sentinels (highest priority, minimal)

Add an `out` flag to the existing function and neutralise it after the flat sample:

```glsl
// A02-P1 / PORT APPROX MITIGATION — not donor parity.
// (3,3)/(7,3) are donor-authored constant-0 sentinels (DALPHA-01 §6.4);
// their measured mean is 0/255 (A02-E4), so :427 would write pure black.
vec2 alpha_patch_uv(float tile, vec2 local, out float mask_is_zero) {
	float id = floor(abs(tile));
	float dir = mod(id, 4.0);
	float row = dir;
	float variant = mod(floor(id / 4.0), 4.0);
	float half = mod(floor(id / 16.0), 2.0);
	float opposite = mod(floor(id / 64.0), 2.0);
	row = mix(row, 3.0 - row, opposite);
	variant = mix(variant, 3.0 - variant, opposite);
	vec2 cell = vec2(half * 4.0 + variant, row);
	mask_is_zero = step(2.5, cell.x) * step(2.5, cell.y); // (3,3) or (7,3)
	vec2 t = clamp(local, 0.0078125, 0.9921875);
	return (cell + t) / vec2(8.0, 4.0);
}

// flat branch:
float zero_flag = 0.0;
a = texture(alpha_atlas, alpha_patch_uv(v_tile, v_alpha_uv, zero_flag)).a;
a = mix(a, 1.0, zero_flag);   // no black cells; label PORT APPROX, A/B required
```

### P2 — Confine the mask to a soft border band (answers Q4)

Insert immediately before `:427`, inside the `face == 0` path or after computing `a`:

```glsl
// A02-P2 / PORT APPROX MITIGATION. v_alpha_uv = fract(v_st*0.5) is the
// cell-local [0,1) coordinate (shader :316, :214). NOTE: the :376 clamp is a
// patch inset, NOT this cell-border band. Narrow band avoids a dark 2 m grid.
vec2 edge_dist = min(v_alpha_uv, 1.0 - v_alpha_uv);
float dmin = min(edge_dist.x, edge_dist.y);
float border = 1.0 - smoothstep(0.02, 0.12, dmin);  // ~4..24 cm of a 2 m cell
a = mix(1.0, a, border);
```

### P3 — Isolate the mask contribution (diagnostic A/B, no shader change)

Set the binding instead of editing shader lines (see `world3d_terrain.gd:718-719`):

```glsl
// A02-P3 / DIAGNOSTIC ONLY. Shader line :427 is unchanged:
//   rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;
// Bind at the material (world3d_terrain.gd _tileindex_material):
//   mat.set_shader_parameter("mask_to_alpha", 0.0);
// mix(1.0,a,0.0)==1.0 => no mask darkening; ALPHA stays 1.0 (:475).
// A/B at identical camera separates mask artifacts from atlas/palette artifacts.
```

### P4 — Compress mask contrast instead of adding noise (guardrail-safe)

No synthetic dither/noise field (CHARTER §3 decision S-25-09). Reduce the *existing* mask's
dynamic range; keeps the donor-grounded patch shape, lowers its visual weight:

```glsl
// A02-P4 / PORT APPROX ART, no donor value claimed. Apply after sampling a.
float a_soft = clamp(a, 0.35, 1.0);   // kill the near-black tail (a=0.18..0.33)
a_soft = mix(a_soft, 1.0, 0.5);       // 50% strength; A/B tune 0.25..0.75
a = a_soft;
```

### P5 — Structurally correct fix: mask only where neighbours differ (needs data handoff)

Requires a neighbour id in the vertex stream (`world3d_terrain.gd`), so **out of A02 scope** —
shader-side sketch only:

```glsl
// A02-P5 / DONOR-GROUNDED STRUCTURE (DALPHA-01 §2.4/§6.4), APPROX binding.
// Add UV3.x = neighbour tile id at the mesh build; then in fragment():
varying float v_neighbour_tile;   // NEW — data-side change required
float differs = step(0.5, abs(v_tile - v_neighbour_tile));
a = mix(1.0, a, differs);         // mask only at real tile transitions
// Still one blend pass, so this is crossfade-APPROX, not donor bmTransparency parity.
```

---

## 5. Recommendation

1. **First, quantify (P3).** Produce the sanctioned `mask_to_alpha=0` A/B at an identical camera.
   If the streaks/blotches vanish, ranks 1–3 are confirmed as the dominant *mask* share; if they
   persist, the charter's atlas-repeat/filter suspects dominate and mask work is secondary.
2. **Then remove the hard defect (P1)** regardless of A/B outcome: 8 black-producing ids,
   including promoted cliff faces, are not defensible as a transition effect.
3. **If mask share is confirmed, reduce visual weight (P4) before any geometric trick.** It is
   guardrail-safe (no new noise field) and preserves the donor-grounded patch structure.
4. **Use P2 only as a fallback** if the residual artifact reads specifically as 2 m banding;
   A/B it against a dark-grid regression.
5. **Route P5 to a future implementation ticket** with a mesh/data owner: it is the only proposal
   that restores the donor's *transition-only* role, and it requires a neighbour-id attribute that
   the current `UV2` contract (DALPHA-02 §5 Q2) does not carry.

**No donor parity claim.** The 64² patch grid is donor-grounded; the tile-id decomposition, the
full-cell RGB multiply, the sentinel guard, the border band, the contrast compression and the
neighbour proposal are all explicitly **PORT APPROXIMATION** and require visual A/B before
shipping. No code was edited and no Godot job was submitted for this ticket.

*End of A02.*
