# Wave 3 — building UX / placement fixes (owner directive 2026-11-24)

Owner: "not all buildings build can be completed, if not enough resources don't even
let build the building; improve building selection make it more beautiful with some
kind of aura instead of white circle; rally points are visible and used when building
is selected and much more."

All claims treated as UNDONE until verified in current source (`WAVE2_CHARTER.md`
rule). Wave 3 opens only after the owning wave-2 files are released.

## Tickets (ownership reserved — no .gd file conflicts with wave 2)

| ID | Owned files (after wave 2 closes) | Scope |
|---|---|---|
| W3-1 | `app/scripts/game.gd` | Placement refuses unaffordable buildings; all building types can complete; no orphan build sites |
| W3-2 | `app/scripts/input_controller.gd`, `app/scripts/hud.gd` | Selection aura instead of white circle; rally point visible + used on selected buildings; related UX polish |
| W3-3 | `app/scripts/world.gd` | Render the selection aura / rally flag art if the drawing lives in the render layer |

## Session ids (wave 3)
| ID | Session |
|---|---|
| W3-1 | ses_df324e7b1ffe9i88Pv4ZGhf2fl |
| W3-2 | ses_df324e7afffeLnpB8foQgPXO6i |
| W3-3 | ses_df324e7acffewX4tMzEohcXDqL |

## Recon (parallel, read-only, DONE)
X1 report landed: `reports/X01_building_ux_sites.md`; rulings in `WAVE3_DECISIONS.md`.

## Recon (parallel, read-only, runs NOW)

| ID | Output | Scope |
|---|---|---|
| X1 | `reports/X01_building_ux_sites.md` | Locate exact code sites + donor evidence for: affordability gating at placement, build-completion paths, selection ring drawing, rally flag rendering/usage, and concrete improvement list. No edits. |

## Gates
Wave 3 workers: backup, disjoint files, one targeted runner test each, coordinator
runs final gate after all reports land.
